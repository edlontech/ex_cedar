defmodule ExCedar.Native do
  @moduledoc false

  version = Mix.Project.config()[:version]

  use RustlerPrecompiled,
    otp_app: :ex_cedar,
    crate: "ex_cedar_native",
    base_url: "https://github.com/edlon/ex_cedar/releases/download/v#{version}",
    force_build: System.get_env("EX_CEDAR_BUILD") != nil or Mix.env() in [:dev, :test],
    version: version

  def cedar_version, do: :erlang.nif_error(:nif_not_loaded)
  def policy_set_from_str(_text), do: :erlang.nif_error(:nif_not_loaded)
  def entities_from_json(_json), do: :erlang.nif_error(:nif_not_loaded)
  def authorize(_ps, _ents, _p, _a, _r, _ctx), do: :erlang.nif_error(:nif_not_loaded)
end
