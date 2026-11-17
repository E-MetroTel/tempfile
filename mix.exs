defmodule Tempfile.Mixfile do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :tempfile,
      version: @version,
      elixir: "~> 1.20",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Tempfile",
      source_url: "https://github.com/sorentwo/tempfile",
      docs: [source_ref: "v#{@version}", extras: ["README.md", "LICENSE.txt"], main: "Tempfile"]
    ]
  end

  def application do
    [
      mod: {Tempfile.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.40", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    Auto cleaning and randomly named temporary files
    """
  end

  defp package do
    [
      maintainers: ["Parker Selbert"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/sorentwo/tempfile"},
      files: ~w(lib priv mix.exs README.md CHANGELOG.md LICENSE.txt)
    ]
  end
end
