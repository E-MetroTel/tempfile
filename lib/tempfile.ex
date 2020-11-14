defmodule Tempfile do
  @moduledoc """
  `Tempfile` is a server specifically for managing temporary files. New random
  file are created in a temporary location and are automatically cleaned up
  when the requesting process exits.

  Because tempfile creation is stateful, the `:tempfile` application must be
  started in order to use the `Tempfile` module.
  """

  defdelegate random(filename), to: Tempfile.File
end
