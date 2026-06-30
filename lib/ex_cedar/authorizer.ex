defmodule ExCedar.Authorizer do
  @moduledoc false

  alias ExCedar.{Decision, EntityUid, Error, Native, Request}

  @spec authorize(term(), term(), Request.t(), keyword()) ::
          {:ok, Decision.t()} | {:error, term()}
  def authorize(policy_set, entities, %Request{} = req, _opts \\ []) do
    :telemetry.span([:ex_cedar, :authorize], %{}, fn ->
      principal = EntityUid.to_string(req.principal)
      action = EntityUid.to_string(req.action)
      resource = EntityUid.to_string(req.resource)
      context_json = req |> Request.context_json() |> IO.iodata_to_binary()

      result =
        case Native.authorize(policy_set, entities, principal, action, resource, context_json) do
          {:ok, raw} -> {:ok, struct(Decision, raw)}
          {:error, msg} -> {:error, Error.to_class([%Error.Request{message: msg}])}
        end

      stop_meta =
        case result do
          {:ok, decision} ->
            %{
              decision: decision.decision,
              determining_policy_count: length(decision.determining_policies)
            }

          {:error, _} ->
            %{error: true}
        end

      {result, stop_meta}
    end)
  end

  @spec authorize!(term(), term(), Request.t(), keyword()) :: Decision.t()
  def authorize!(policy_set, entities, %Request{} = req, opts \\ []) do
    Error.unwrap!(authorize(policy_set, entities, req, opts))
  end
end
