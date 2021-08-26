defmodule ElixirNixExample.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_nix_example,
      version: "0.1.0",
      deps: [],
      releases: [
        example: [
          include_executables_for: [:unix]
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ElixirNixExample.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end
end
