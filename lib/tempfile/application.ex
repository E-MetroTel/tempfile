defmodule Tempfile.Application do
  use Application

  def start(_, _) do
    children = [
      {Tempfile.File, []}
    ]

    options = [strategy: :one_for_one, name: Tempfile.Supervisor]

    Supervisor.start_link(children, options)
  end
end
