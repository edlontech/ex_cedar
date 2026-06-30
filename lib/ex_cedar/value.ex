defmodule ExCedar.Value do
  @moduledoc false

  alias ExCedar.{Decimal, EntityUid, IpAddr}

  @spec encode(term()) :: term()
  def encode(v) when is_boolean(v), do: v
  def encode(v) when is_integer(v), do: v
  def encode(v) when is_binary(v), do: v
  def encode(v) when is_list(v), do: Enum.map(v, &encode/1)
  def encode(%EntityUid{} = uid), do: %{"__entity" => EntityUid.to_json(uid)}
  def encode(%Decimal{value: value}), do: %{"__extn" => %{"fn" => "decimal", "arg" => value}}
  def encode(%IpAddr{value: value}), do: %{"__extn" => %{"fn" => "ip", "arg" => value}}

  def encode(v) when is_map(v) and not is_struct(v) do
    Map.new(v, fn {k, val} -> {to_string(k), encode(val)} end)
  end

  def encode(other) do
    raise ArgumentError,
          "cannot encode #{inspect(other)} as a Cedar value: Cedar has no float, null, atom, or tuple type"
  end
end
