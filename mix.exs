defmodule Interceptor.MixProject do
  use Mix.Project

  def project do
    [
      app: :interceptor,
      package: package(),
      source_url: "https://github.com/amalbuquerque/interceptor",
      version: "0.1.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: [main: "Interceptor",
        logo: "assets/images/interceptor_logo_small.png",
        assets: "assets"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
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
