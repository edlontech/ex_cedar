defmodule ExCedar.Context do
  @moduledoc false

  alias ExCedar.Value

  defstruct attributes: %{}

  @type t :: %__MODULE__{attributes: map()}

  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map), do: %__MODULE__{attributes: map}

  @spec to_json(t()) :: map()
  def to_json(%__MODULE__{attributes: attributes}), do: Value.encode(attributes)
end
