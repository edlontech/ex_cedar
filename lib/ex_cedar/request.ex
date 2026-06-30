defmodule ExCedar.Request do
  @moduledoc """
  Cedar authorization request.

  Groups `principal`, `action`, and `resource` as `ExCedar.EntityUid` structs
  and an optional `context` as a plain map or `ExCedar.Context` struct.

      %ExCedar.Request{
        principal: ExCedar.EntityUid.new("User", "alice"),
        action:    ExCedar.EntityUid.new("Action", "view"),
        resource:  ExCedar.EntityUid.new("Document", "doc1"),
        context:   %{"mfa" => true}
      }
  """

  alias ExCedar.{Context, EntityUid, Value}

  defstruct [:principal, :action, :resource, context: %ExCedar.Context{}]

  @type t :: %__MODULE__{
          principal: EntityUid.t(),
          action: EntityUid.t(),
          resource: EntityUid.t(),
          context: Context.t() | map()
        }

  @doc false
  @spec context_json(t()) :: binary()
  def context_json(%__MODULE__{context: context}) do
    context |> encode_context() |> JSON.encode!()
  end

  defp encode_context(%Context{} = ctx), do: Context.to_json(ctx)
  defp encode_context(map) when is_map(map), do: Value.encode(map)
end
