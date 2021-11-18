defmodule ForthVM.MixProject do
  @moduledoc false
  use Mix.Project

  @version "0.5.0"

  def project do
    [
      name: "ForthVM",
      source_url: "https://github.com/alexiob/forthvm",
      homepage_url: "https://github.com/alexiob/forthvm",
      app: :forthvm,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      dialyzer: [
        plt_add_apps: [:mix],
        ignore_warnings: ".dialyzer_ignore.exs"
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      docs: [
        main: "ForthVM",
        extras: ["README.md", "LICENSE"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.10", only: :test, runtime: false},
      {:rexbug, ">= 1.0.0", only: :test},
      {:ex_doc, "~> 0.25.5", only: [:dev], runtime: false}
    ]
  end

  defp description do
    """
    A toy Forth-like virtual machine.
    """
  end

  # https://hex.pm/docs/publish
  defp package do
    [
      name: :forthvm,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Alessandro Iob <alessandro.iob@gmail.com>"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/alexiob/forthvm"
      }
    ]
  end
end
