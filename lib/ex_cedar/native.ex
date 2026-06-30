defmodule ExCedar.Native do
  version = Mix.Project.config()[:version]

  use RustlerPrecompiled,
    otp_app: :ex_cedar,
    crate: "ex_cedar_native",
    base_url: "https://github.com/edlon/ex_cedar/releases/download/v#{version}",
    force_build: System.get_env("EX_CEDAR_BUILD") != nil or Mix.env() in [:dev, :test],
    version: version

  def cedar_version, do: :erlang.nif_error(:nif_not_loaded)
end
