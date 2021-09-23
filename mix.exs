defmodule Slurp.MixProject do
  use Mix.Project

  def project do
    [
      app: :slurp,
      version: "0.0.9",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      description: description(),
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      package: package(),
      test_paths: ["lib"],
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs"
      ]
    ]
  end

  def application do
    [
      mod: {Slurp.Application, []},
      start_phases: [
        hydrate: [],
        blockchains_and_subscriptions: []
      ],
      extra_applications: [:logger, :iex]
    ]
  end

  defp deps do
    [
      {:enumerati, "~> 0.0.8"},
      {:ex_doc, "~> 0.22"},
      # ex_abi ~> 0.5.5 required for decoding of output without method_id prefix
      # https://github.com/poanetwork/ex_abi/pull/61
      {:ex_abi, "~> 0.5.5"},
      {:exw3, "~> 0.6"},
      {:juice, "~> 0.0.3"},
      {:proper_case, "~> 1.0"},
      {:stored, "~> 0.0.7"},
      {:table_rex, "~> 3.0"},
      {:telemetry, "~> 0.4"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:telemetry_metrics_prometheus, "~> 1.0"},
      {:logger_file_backend, "~> 0.0.10", only: [:dev, :test]},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:mock, "~> 0.3.0", only: :test},
      {:ex_unit_notifier, "~> 1.0", only: :test}
    ]
  end

  defp description do
    "An EVM block ingestion toolkit for Elixir"
  end

  defp package do
    %{
      licenses: ["MIT"],
      maintainers: ["Alex Kwiatkowski"],
      links: %{"GitHub" => "https://github.com/fremantle-industries/slurp"}
    }
  end

  defp elixirc_paths(env) when env == :test or env == :dev, do: ["lib", "examples"]
  defp elixirc_paths(_), do: ["lib"]
end
