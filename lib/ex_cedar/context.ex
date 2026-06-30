defmodule ExCedar.Context do
  @moduledoc """
  Cedar request context.

  Wraps a map of attributes that Cedar can reference in policy conditions.
  Attribute values are encoded as Cedar JSON record values via the same rules
  as `ExCedar.Entity` attributes.

  Plain maps can be used directly in `ExCedar.Request` without wrapping in
  this struct — the authorizer handles both forms.
  """

  alias ExCedar.Value

  defstruct attributes: %{}

  @type t :: %__MODULE__{attributes: map()}

  @doc "Wraps a plain map in a `Context` struct."
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map), do: %__MODULE__{attributes: map}

  @doc "Encodes the context as a Cedar JSON record value."
  @spec to_json(t()) :: map()
  def to_json(%__MODULE__{attributes: attributes}), do: Value.encode(attributes)
end
