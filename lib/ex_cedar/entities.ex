defmodule ExCedar.Entities do
  @moduledoc """
  Compiled Cedar entity store handle.

  Build an entity store from a list of `ExCedar.Entity` structs via
  `from_list/1`, or pass raw Cedar entities JSON via `from_json/1`. The
  compiled handle is immutable and thread-safe.
  """

  alias ExCedar.{Entity, Error, Native}

  @doc """
  Encodes a list of `ExCedar.Entity` structs to Cedar entities JSON and
  returns a compiled handle.

  Returns `{:error, %ExCedar.Error.Invalid{}}` if Cedar rejects the entity
  data (e.g. a duplicate entity UID or a malformed entity reference).
  """
  def from_list(entities) when is_list(entities) do
    json =
      entities
      |> Enum.map(&Entity.to_json/1)
      |> :json.encode()
      |> IO.iodata_to_binary()

    call_nif(json)
  end

  @doc """
  Parses raw Cedar entities JSON (binary string, list, or map) and returns a
  compiled handle. Useful as an escape hatch when working with Cedar JSON
  produced by other tools.
  """
  def from_json(json) when is_binary(json) do
    call_nif(json)
  end

  def from_json(term) when is_list(term) or is_map(term) do
    json = term |> :json.encode() |> IO.iodata_to_binary()
    call_nif(json)
  end

  defp call_nif(json) do
    with {:error, msg} <- Native.entities_from_json(json) do
      {:error, Error.to_class([%Error.Entities{message: msg}])}
    end
  end
end
