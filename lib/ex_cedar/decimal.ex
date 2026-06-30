defmodule ExCedar.Decimal do
  @moduledoc """
  Cedar `decimal` extension value.

  Construct with `new/1` and use in entity attributes or request context maps.
  Cedar encodes these as `{"__extn": {"fn": "decimal", "arg": value}}`.

      ExCedar.Decimal.new("3.14")
  """

  defstruct [:value]

  @type t :: %__MODULE__{value: String.t()}

  @doc "Wraps a decimal string in a `Decimal` extension value struct."
  @spec new(String.t()) :: t()
  def new(value) when is_binary(value), do: %__MODULE__{value: value}
end
