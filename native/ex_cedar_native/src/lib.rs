use cedar_policy::PolicySet;
use rustler::{Resource, ResourceArc};

const CEDAR_VERSION: &str = env!("CEDAR_POLICY_VERSION");

pub struct PolicySetResource(pub PolicySet);

#[rustler::resource_impl]
impl Resource for PolicySetResource {}

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

rustler::init!("Elixir.ExCedar.Native");
