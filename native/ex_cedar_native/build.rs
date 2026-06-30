use std::fs;
use std::path::Path;

fn main() {
    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR").unwrap();
    let lock_path = Path::new(&manifest_dir).join("Cargo.lock");

    println!("cargo:rerun-if-changed=Cargo.lock");

    let content = fs::read_to_string(&lock_path).expect("Cargo.lock not found");
    let version = parse_cedar_version(&content).expect("cedar-policy not found in Cargo.lock");

    println!("cargo:rustc-env=CEDAR_POLICY_VERSION={version}");
}

fn parse_cedar_version(content: &str) -> Option<String> {
    content
        .split("[[package]]")
        .find(|block| block.contains(r#"name = "cedar-policy""#))?
        .lines()
        .find_map(|line| {
            line.trim()
                .strip_prefix("version = \"")?
                .strip_suffix('"')
                .map(str::to_owned)
        })
}
