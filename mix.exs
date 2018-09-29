defmodule Interceptor.MixProject do
  use Mix.Project

  def project do
    [
      app: :interceptor,
      package: package(),
      source_url: "https://github.com/amalbuquerque/interceptor",
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
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
      {:ex_doc, ">= 0.0.0", only: :dev},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/intercepted_modules"]
  defp elixirc_paths(_), do: ["lib"]

  defp package() do
    [
      description: "Library to easily intercept function calls",
      licenses: ["MIT"],
      maintainers: ["andre.malbuq@gmail.com"],
      links: %{
        Github: "https://github.com/amalbuquerque/interceptor"
      },
    ]
  end
end
