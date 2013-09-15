defmodule Elixirjuju.Mixfile do
  use Mix.Project

  def project do
    [ app: :elixirjuju,
      version: "0.0.1",
      elixir: "~> 0.10.2",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:socket, :crypto, :httpotion, :jsonex] ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [
      {:socket, [github: "meh/elixir-socket"]},
      {:httpotion,"0.2.2", [github: "myfreeweb/httpotion"]},
      {:jsonex,"2.0", [github: "marcelog/jsonex", tag: "2.0"]},
    ]
  end
end
