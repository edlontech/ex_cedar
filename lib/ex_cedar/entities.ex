defmodule ExCedar.Entities do
  @moduledoc false

  alias ExCedar.{Entity, Error, Native}

  def from_list(entities) when is_list(entities) do
    json =
      entities
      |> Enum.map(&Entity.to_json/1)
      |> :json.encode()
      |> IO.iodata_to_binary()

    call_nif(json)
  end

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
