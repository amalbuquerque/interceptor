defmodule Interceptor.MixProject do
  use Mix.Project

  def project do
    [
      app: :interceptor,
      package: package(),
      source_url: "https://github.com/amalbuquerque/interceptor",
      version: "0.5.3",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev},
      {:mox, "0.5.1", only: :test},
      {:excoveralls, "~> 0.12.0", only: :test},
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib", "test/intercepted_modules"]
  defp elixirc_paths(:dev), do: ["lib", "test/intercepted_modules/minefield.ex"]
  defp elixirc_paths(_), do: ["lib"]

  defp docs() do
    [
      main: "Interceptor",
      canonical: "https://hexdocs.pm/interceptor",
      source_url: "https://github.com/amalbuquerque/interceptor",
      logo: "assets/images/interceptor_logo_small.png",
      assets: "assets"
    ]
  end

  defp package() do
    [
      description: "Library to easily intercept function calls",
      licenses: ["MIT"],
      maintainers: ["André Albuquerque"],
      links: %{
        Github: "https://github.com/amalbuquerque/interceptor"
      },
    ]
  end
end
