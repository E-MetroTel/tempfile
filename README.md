# Tempfile

[![Build Status](https://travis-ci.org/sorentwo/tempfile.svg?branch=master)](https://travis-ci.org/sorentwo/tempfile)

`Tempfile` is a server specifically for managing temporary files. New random
file are created in a temporary location and are automatically cleaned up when
the requesting process exits.

Because tempfile creation is stateful, the `:tempfile` application must be
started in order to use the `Tempfile` module.

## Acknowledgements & Alternatives

This is almost entirely a port of [plug's][plug] `Plug.Upload` module. There are
some slight modifications around file naming, but the `GenServer` itself is
derived wholesale from `Plug`.

If you want a more robust alternative look at [briefly][briefly], which also
provides temporary file handling (but has a less discoverable name).

## Installation

The package can be installed from hex as `tempfile`:

1. Add tempfile to your list of dependencies in `mix.exs`:

      def deps do
        [{:tempfile, "~> 0.1.0"}]
      end

Mix starts the runtime dependency before your application.

## Usage

Create a new temporary file with a basename and extension:

```elixir
{:ok, path} = Tempfile.random("tempfile.txt")
File.write!(path, "I am a text file")
```

When the calling process exits the file will be removed automatically.

## Elixir 1.20 development

The `.tool-versions` file selects Elixir `1.20.4-otp-29` and Erlang `29.1.2`.
Install these with asdf, then run:

```sh
mix deps.get
mix compile --force --warnings-as-errors
mix test --warnings-as-errors
mix test --cover
MIX_ENV=test mix compile --force --warnings-as-errors
MIX_ENV=prod mix compile --force --warnings-as-errors
mix docs --warnings-as-errors
mix format --check-formatted
```

Tests use the local filesystem and require a writable temporary directory.
The server selects `TMPDIR`, `TMP`, or `TEMP`, falling back to `/tmp`, and stores
its files in a `tempfile` subdirectory. Each file belongs to the process that
called `Tempfile.random/1`; keep that process alive until the file is no longer
needed. Tests cover unique filenames, multiple files per owner, cleanup after
owner exit, and isolation between owners.

ExDoc is a development-only dependency. The generated documentation includes this
README and the license.

## License

MIT License, see [LICENSE.txt](LICENSE.txt) for details.

[plug]: https://hex.pm/packages/plug
[briefly]: https://hex.pm/packages/briefly
