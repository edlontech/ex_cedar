defmodule ExCedar.Request do
  @moduledoc false

  alias ExCedar.{Context, EntityUid, Value}

  defstruct [:principal, :action, :resource, context: %ExCedar.Context{}]

  @type t :: %__MODULE__{
          principal: EntityUid.t(),
          action: EntityUid.t(),
          resource: EntityUid.t(),
          context: Context.t() | map()
        }

  @spec to_parts(t()) :: {map(), map(), map(), map()}
  def to_parts(%__MODULE__{
        principal: principal,
        action: action,
        resource: resource,
        context: context
      }) do
    {
      EntityUid.to_json(principal),
      EntityUid.to_json(action),
      EntityUid.to_json(resource),
      encode_context(context)
    }
  end

  defp encode_context(%Context{} = ctx), do: Context.to_json(ctx)
  defp encode_context(map) when is_map(map), do: Value.encode(map)
end
