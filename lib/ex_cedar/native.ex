defmodule ExCedar.Native do
  @moduledoc false

  version = Mix.Project.config()[:version]

  use RustlerPrecompiled,
    otp_app: :ex_cedar,
    crate: "ex_cedar_native",
    base_url: "https://github.com/edlon/ex_cedar/releases/download/v#{version}",
    force_build: System.get_env("EX_CEDAR_BUILD") in ["1", "true"],
    version: version,
    targets: ~w(
      x86_64-unknown-linux-gnu
      aarch64-unknown-linux-gnu
      x86_64-unknown-linux-musl
      aarch64-unknown-linux-musl
      x86_64-apple-darwin
      aarch64-apple-darwin
      x86_64-pc-windows-msvc
    ),
    nif_versions: ["2.15"]

  def cedar_version, do: :erlang.nif_error(:nif_not_loaded)
  def policy_set_from_str(_text), do: :erlang.nif_error(:nif_not_loaded)
  def entities_from_json(_json), do: :erlang.nif_error(:nif_not_loaded)
  def authorize(_ps, _ents, _p, _a, _r, _ctx, _schema), do: :erlang.nif_error(:nif_not_loaded)
  def schema_from_str(_text), do: :erlang.nif_error(:nif_not_loaded)
  def schema_from_json(_json), do: :erlang.nif_error(:nif_not_loaded)
  def validate(_ps, _schema, _mode), do: :erlang.nif_error(:nif_not_loaded)

  def policy_set_link_template(_ps, _tmpl_id, _new_id, _principal, _resource),
    do: :erlang.nif_error(:nif_not_loaded)

  def policy_set_policy_ids(_ps), do: :erlang.nif_error(:nif_not_loaded)
  def policy_set_template_ids(_ps), do: :erlang.nif_error(:nif_not_loaded)
end
