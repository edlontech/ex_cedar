defmodule ExCedar.Decimal do
  @moduledoc false

  defstruct [:value]

  @type t :: %__MODULE__{value: String.t()}

  @spec new(String.t()) :: t()
  def new(value) when is_binary(value), do: %__MODULE__{value: value}
end
