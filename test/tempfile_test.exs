defmodule TempfileTest do
  use ExUnit.Case, async: true

  test "random/1 is available as a top level function" do
    {:ok, path} = Tempfile.random("testfile.txt")

    assert File.exists?(path)
    assert File.read!(path) == ""
  end
end
