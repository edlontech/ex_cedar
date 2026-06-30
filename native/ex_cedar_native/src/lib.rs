const CEDAR_VERSION: &str = env!("CEDAR_POLICY_VERSION");

#[rustler::nif]
fn cedar_version() -> &'static str {
    CEDAR_VERSION
}

rustler::init!("Elixir.ExCedar.Native");
