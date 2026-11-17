defmodule Tempfile.FileTest do
  use ExUnit.Case, async: true

  alias Tempfile.File, as: Temp

  doctest Tempfile.File

  test "random files are returned and removed on exit" do
    {pid, ref, [path]} = start_owner(["testfile.png"])
    assert File.exists?(path)
    assert File.read!(path) == ""

    stop_owner(pid, ref, [path])
  end

  test "temporary files have globally unique names" do
    {:ok, path} = Temp.random("testfile.txt")
    assert path =~ ~r/testfile-\d+-\d+-\d+\.txt$/
  end

  test "all files belonging to the same process are removed" do
    {pid, ref, paths} = start_owner(["testfile.txt", "testfile.txt"])
    assert length(Enum.uniq(paths)) == 2
    assert Enum.all?(paths, &File.exists?/1)

    stop_owner(pid, ref, paths)
  end

  test "exiting one owner preserves another owner's files" do
    {pid1, ref1, paths1} = start_owner(["testfile.txt"])
    {pid2, ref2, paths2} = start_owner(["testfile.txt"])

    stop_owner(pid1, ref1, paths1)
    assert Enum.all?(paths2, &File.exists?/1)
    stop_owner(pid2, ref2, paths2)
  end

  test "keeps the filename and extension without the supplied directory" do
    {:ok, path} = Temp.random("some/directory/archive.tar.gz")

    assert Path.basename(path) =~ ~r/^archive\.tar-\d+-\d+-\d+\.gz$/
    assert File.exists?(path)
  end

  test "unrelated messages and unknown owner notifications preserve files" do
    {pid, ref, paths} = start_owner(["testfile.txt"])
    send(Temp, :unrelated)
    send(Temp, {:DOWN, make_ref(), :process, self(), :normal})

    # A call from the same sender flushes the preceding notifications.
    {:ok, control_path} = Temp.random("control.txt")
    assert File.exists?(control_path)
    assert Enum.all?(paths, &File.exists?/1)
    stop_owner(pid, ref, paths)
    assert File.exists?(control_path)
  end

  defp start_owner(filenames) do
    parent = self()

    {pid, ref} =
      spawn_monitor(fn ->
        paths =
          Enum.map(filenames, fn filename ->
            {:ok, path} = Temp.random(filename)
            path
          end)

        send(parent, {:paths, self(), paths})

        receive do
          :stop -> :ok
        end
      end)

    on_exit(fn -> if Process.alive?(pid), do: Process.exit(pid, :kill) end)
    assert_receive {:paths, ^pid, paths}
    {pid, ref, paths}
  end

  defp stop_owner(pid, ref, paths) do
    send(pid, :stop)
    assert_receive {:DOWN, ^ref, :process, ^pid, :normal}
    await_cleanup(paths, System.monotonic_time(:millisecond) + 1000)
  end

  defp await_cleanup(paths, deadline) do
    if Enum.any?(paths, &File.exists?/1) do
      assert System.monotonic_time(:millisecond) < deadline, "temporary files were not cleaned up"
      Process.sleep(1)
      await_cleanup(paths, deadline)
    end
  end
end
