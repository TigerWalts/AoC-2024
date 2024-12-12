defmodule Aoc2024.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc2024,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Aoc2024.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:flow, "~> 1.2"}
    ]
  end
end
