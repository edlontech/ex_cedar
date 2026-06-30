defmodule ExCedar.Authorizer do
  @moduledoc false

  alias ExCedar.{Decision, EntityUid, Error, Native, Request}

  @spec authorize(term(), term(), Request.t(), keyword()) ::
          {:ok, Decision.t()} | {:error, term()}
  def authorize(policy_set, entities, %Request{} = req, _opts \\ []) do
    principal = EntityUid.to_string(req.principal)
    action = EntityUid.to_string(req.action)
    resource = EntityUid.to_string(req.resource)
    context_json = req |> Request.context_json() |> IO.iodata_to_binary()

    case Native.authorize(policy_set, entities, principal, action, resource, context_json) do
      {:ok, result} -> {:ok, struct(Decision, result)}
      {:error, msg} -> {:error, Error.to_class([%Error.Request{message: msg}])}
    end
  end

  @spec authorize!(term(), term(), Request.t(), keyword()) :: Decision.t()
  def authorize!(policy_set, entities, %Request{} = req, opts \\ []) do
    Error.unwrap!(authorize(policy_set, entities, req, opts))
  end
end
