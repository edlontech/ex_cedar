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

  @spec context_json(t()) :: iodata()
  def context_json(%__MODULE__{context: context}) do
    context |> encode_context() |> :json.encode()
  end

  defp encode_context(%Context{} = ctx), do: Context.to_json(ctx)
  defp encode_context(map) when is_map(map), do: Value.encode(map)
end
