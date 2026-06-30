defmodule ExCedar.Schema do
  @moduledoc """
  Compiled Cedar schema handle.

  Accepts human-syntax Cedar schemas via `compile/1` and Cedar JSON schemas
  via `from_json/1`. The compiled handle is immutable, thread-safe, and can be
  passed to `ExCedar.Validator.validate/3` or supplied as the `schema:` option
  on `ExCedar.Authorizer.authorize/4`.

  Like all compiled handles, it does not survive a node restart.
  """

  alias ExCedar.{Error, Native}

  @doc """
  Parses human-syntax Cedar schema text and returns a compiled handle.

  Returns `{:error, %ExCedar.Error.Invalid{}}` on a schema syntax error.
  """
  def compile(text) when is_binary(text) do
    wrap_nif(Native.schema_from_str(text))
  end

  @doc "Like `compile/1` but raises an `ExCedar.Error` exception on failure."
  def compile!(text) do
    Error.unwrap!(compile(text))
  end

  @doc """
  Parses a Cedar JSON schema (binary string or map) and returns a compiled
  handle.

  Returns `{:error, %ExCedar.Error.Invalid{}}` on a schema error.
  """
  def from_json(json) when is_binary(json) do
    wrap_nif(Native.schema_from_json(json))
  end

  def from_json(term) when is_map(term) do
    json = JSON.encode!(term)
    wrap_nif(Native.schema_from_json(json))
  end

  @doc "Like `from_json/1` but raises an `ExCedar.Error` exception on failure."
  def from_json!(json) do
    Error.unwrap!(from_json(json))
  end

  defp wrap_nif({:ok, _} = ok), do: ok

  defp wrap_nif({:error, msg}) do
    {:error, Error.to_class([%Error.Schema{message: msg, details: nil}])}
  end
end
