use cedar_policy::{
    Authorizer, Context, Decision, Entities, EntityUid, PolicyId, PolicySet, Request, Schema,
    SlotId, ValidationMode as CedarValidationMode, Validator,
};
use rustler::{Resource, ResourceArc};
use std::collections::HashMap;

const CEDAR_VERSION: &str = env!("CEDAR_POLICY_VERSION");

pub struct PolicySetResource(pub PolicySet);

#[rustler::resource_impl]
impl Resource for PolicySetResource {}

pub struct EntitiesResource(pub Entities);

#[rustler::resource_impl]
impl Resource for EntitiesResource {}

pub struct SchemaResource(pub Schema);

#[rustler::resource_impl]
impl Resource for SchemaResource {}

#[derive(rustler::NifUnitEnum)]
enum AuthzDecision {
    Allow,
    Deny,
}

#[derive(rustler::NifUnitEnum)]
enum ValidateMode {
    Strict,
}

#[derive(rustler::NifMap)]
struct Finding {
    policy_id: String,
    message: String,
}

#[derive(rustler::NifMap)]
struct ValidateResult {
    errors: Vec<Finding>,
    warnings: Vec<Finding>,
}

#[derive(rustler::NifMap)]
struct AuthzResult {
    decision: AuthzDecision,
    determining_policies: Vec<String>,
    errors: Vec<String>,
}

#[rustler::nif]
fn cedar_version() -> &'static str {
    CEDAR_VERSION
}

#[rustler::nif(schedule = "DirtyCpu")]
fn policy_set_from_str(text: String) -> Result<ResourceArc<PolicySetResource>, Vec<String>> {
    match text.parse::<PolicySet>() {
        Ok(ps) => Ok(ResourceArc::new(PolicySetResource(ps))),
        Err(e) => Err(e.iter().map(|err| err.to_string()).collect()),
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
fn entities_from_json(json: String) -> Result<ResourceArc<EntitiesResource>, String> {
    Entities::from_json_str(&json, None)
        .map(|e| ResourceArc::new(EntitiesResource(e)))
        .map_err(|e| e.to_string())
}

#[rustler::nif(schedule = "DirtyCpu")]
fn authorize(
    policy_set: ResourceArc<PolicySetResource>,
    entities: ResourceArc<EntitiesResource>,
    principal: String,
    action: String,
    resource: String,
    context_json: String,
    schema: Option<ResourceArc<SchemaResource>>,
) -> Result<AuthzResult, String> {
    let principal: EntityUid = principal
        .parse()
        .map_err(|e: cedar_policy::ParseErrors| e.to_string())?;
    let action: EntityUid = action
        .parse()
        .map_err(|e: cedar_policy::ParseErrors| e.to_string())?;
    let resource: EntityUid = resource
        .parse()
        .map_err(|e: cedar_policy::ParseErrors| e.to_string())?;
    let context = Context::from_json_str(&context_json, None).map_err(|e| e.to_string())?;
    let request = Request::new(
        principal,
        action,
        resource,
        context,
        schema.as_ref().map(|s| &s.0),
    )
    .map_err(|e| e.to_string())?;

    let response = Authorizer::new().is_authorized(&request, &policy_set.0, &entities.0);

    Ok(AuthzResult {
        decision: match response.decision() {
            Decision::Allow => AuthzDecision::Allow,
            Decision::Deny => AuthzDecision::Deny,
        },
        determining_policies: response
            .diagnostics()
            .reason()
            .map(|id| id.to_string())
            .collect(),
        errors: response
            .diagnostics()
            .errors()
            .map(|e| e.to_string())
            .collect(),
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
fn schema_from_str(text: String) -> Result<ResourceArc<SchemaResource>, String> {
    Schema::from_cedarschema_str(&text)
        .map(|(schema, _warnings)| ResourceArc::new(SchemaResource(schema)))
        .map_err(|e| e.to_string())
}

#[rustler::nif(schedule = "DirtyCpu")]
fn schema_from_json(json: String) -> Result<ResourceArc<SchemaResource>, String> {
    Schema::from_json_str(&json)
        .map(|schema| ResourceArc::new(SchemaResource(schema)))
        .map_err(|e| e.to_string())
}

#[rustler::nif(schedule = "DirtyCpu")]
fn validate(
    policy_set: ResourceArc<PolicySetResource>,
    schema: ResourceArc<SchemaResource>,
    mode: ValidateMode,
) -> ValidateResult {
    let cedar_mode = match mode {
        ValidateMode::Strict => CedarValidationMode::Strict,
    };
    let result = Validator::new(schema.0.clone()).validate(&policy_set.0, cedar_mode);
    ValidateResult {
        errors: result
            .validation_errors()
            .map(|e| Finding {
                policy_id: e.policy_id().to_string(),
                message: e.to_string(),
            })
            .collect(),
        warnings: result
            .validation_warnings()
            .map(|w| Finding {
                policy_id: w.policy_id().to_string(),
                message: w.to_string(),
            })
            .collect(),
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
fn policy_set_link_template(
    policy_set: ResourceArc<PolicySetResource>,
    template_id: String,
    new_id: String,
    principal: Option<String>,
    resource: Option<String>,
) -> Result<ResourceArc<PolicySetResource>, String> {
    let mut cloned = policy_set.0.clone();

    let mut vals: HashMap<SlotId, EntityUid> = HashMap::new();
    if let Some(p) = principal {
        let uid: EntityUid = p
            .parse()
            .map_err(|e: cedar_policy::ParseErrors| e.to_string())?;
        vals.insert(SlotId::principal(), uid);
    }
    if let Some(r) = resource {
        let uid: EntityUid = r
            .parse()
            .map_err(|e: cedar_policy::ParseErrors| e.to_string())?;
        vals.insert(SlotId::resource(), uid);
    }

    cloned
        .link(PolicyId::new(template_id), PolicyId::new(new_id), vals)
        .map_err(|e| e.to_string())?;

    Ok(ResourceArc::new(PolicySetResource(cloned)))
}

#[rustler::nif]
fn policy_set_policy_ids(policy_set: ResourceArc<PolicySetResource>) -> Vec<String> {
    policy_set
        .0
        .policies()
        .map(|p| p.id().to_string())
        .collect()
}

#[rustler::nif]
fn policy_set_template_ids(policy_set: ResourceArc<PolicySetResource>) -> Vec<String> {
    policy_set
        .0
        .templates()
        .map(|t| t.id().to_string())
        .collect()
}

rustler::init!("Elixir.ExCedar.Native");
