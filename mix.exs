defmodule Slurp.MixProject do
  use Mix.Project

  def project do
    [
      app: :slurp,
      version: "0.0.1",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      description: description(),
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
      start_phases: [hydrate: []],
      extra_applications: [:logger, :iex]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.22"},
      {:enumerati, "~> 0.0.8"},
      {:stored, "~> 0.0.7"},
      {:table_rex, "~> 3.0"},
      {:logger_file_backend_with_formatters, "~> 0.0.1", only: [:dev, :test]},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:ex_unit_notifier, "~> 0.1", only: :test}
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
end
