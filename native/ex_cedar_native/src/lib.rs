use cedar_policy::{Entities, PolicySet};
use rustler::{Resource, ResourceArc};

const CEDAR_VERSION: &str = env!("CEDAR_POLICY_VERSION");

pub struct PolicySetResource(pub PolicySet);

#[rustler::resource_impl]
impl Resource for PolicySetResource {}

pub struct EntitiesResource(pub Entities);

#[rustler::resource_impl]
impl Resource for EntitiesResource {}

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

rustler::init!("Elixir.ExCedar.Native");
