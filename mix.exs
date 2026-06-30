defmodule ExCedar.MixProject do
  use Mix.Project

  @source_url "https://github.com/edlontech/ex_cedar"

  def project do
    [
      app: :ex_cedar,
      version: "0.1.2",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      description:
        "Elixir bindings for the Cedar authorization policy engine via precompiled NIFs",
      source_url: @source_url,
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :telemetry]
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url},
      files: [
        "lib",
        "native/ex_cedar_native/src",
        "native/ex_cedar_native/Cargo.toml",
        "native/ex_cedar_native/Cargo.lock",
        "native/ex_cedar_native/build.rs",
        "checksum-Elixir.ExCedar.Native.exs",
        "mix.exs",
        "mix.lock",
        "README.md",
        ".formatter.exs"
      ]
    ]
  end

  defp docs do
    [
      main: "ExCedar",
      source_url: @source_url,
      extras: ["README.md"],
      groups_for_modules: [
        Artifacts: [ExCedar.PolicySet, ExCedar.Schema, ExCedar.Entities],
        Requests: [
          ExCedar.EntityUid,
          ExCedar.Entity,
          ExCedar.Request,
          ExCedar.Context,
          ExCedar.Decimal,
          ExCedar.IpAddr
        ],
        Operations: [ExCedar.Authorizer, ExCedar.Validator],
        Results: [ExCedar.Decision, ExCedar.ValidationResult],
        Errors: [ExCedar.Error],
        Telemetry: [ExCedar.Telemetry]
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:splode, "~> 0.3"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:doctor, "~> 0.22", only: :dev},
      {:ex_check, "~> 0.16", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:mix_audit, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:rustler, "~> 0.38.0", runtime: false},
      {:rustler_precompiled, "~> 0.9"},
      {:stream_data, "~> 1.1", only: [:dev, :test]},
      {:telemetry, "~> 1.3"}
    ]
  end
end
