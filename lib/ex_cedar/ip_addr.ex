defmodule ExCedar.IpAddr do
  @moduledoc """
  Cedar `ip` extension value.

  Construct with `new/1` and use in entity attributes or request context maps.
  Cedar encodes these as `{"__extn": {"fn": "ip", "arg": value}}`.

      ExCedar.IpAddr.new("192.168.0.1")
      ExCedar.IpAddr.new("192.168.0.0/24")
  """

  defstruct [:value]

  @type t :: %__MODULE__{value: String.t()}

  @doc "Wraps an IP address or CIDR string in an `IpAddr` extension value struct."
  @spec new(String.t()) :: t()
  def new(value) when is_binary(value), do: %__MODULE__{value: value}
end
