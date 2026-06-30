defmodule ExCedar.Authorizer do
  @moduledoc """
  Authorization over compiled handles.

  Use `ExCedar.authorize/4` for a stateless one-shot call. Use this module
  when you need to authorize multiple requests against the same pre-compiled
  `PolicySet` and `Entities` without recompiling on each call.

  ## Example

      {:ok, ps}   = ExCedar.PolicySet.compile(policy_text)
      {:ok, ents} = ExCedar.Entities.from_list(entities)
      {:ok, %ExCedar.Decision{decision: :allow}} =
        ExCedar.Authorizer.authorize(ps, ents, request)

  Pass `schema:` (a compiled `ExCedar.Schema` handle) to validate the request
  shape and enable type-aware evaluation.
  """

  alias ExCedar.{Decision, EntityUid, Error, Native, Request}

  @doc """
  Runs authorization over compiled `policy_set` and `entities` handles.

  Options:
  - `:schema` — a compiled `ExCedar.Schema` handle; validates the request
    against the schema before evaluating.

  Returns `{:ok, %ExCedar.Decision{}}` on success, or
  `{:error, %ExCedar.Error.Invalid{}}` if the request is invalid (e.g.
  principal type not in schema).

  Emits `[:ex_cedar, :authorize, :start | :stop | :exception]` telemetry —
  see `ExCedar.Telemetry`.
  """
  @spec authorize(term(), term(), Request.t(), keyword()) ::
          {:ok, Decision.t()} | {:error, term()}
  def authorize(policy_set, entities, %Request{} = req, opts \\ []) do
    :telemetry.span([:ex_cedar, :authorize], %{}, fn ->
      principal = EntityUid.to_string(req.principal)
      action = EntityUid.to_string(req.action)
      resource = EntityUid.to_string(req.resource)
      context_json = req |> Request.context_json() |> IO.iodata_to_binary()
      schema = Keyword.get(opts, :schema)

      result =
        case Native.authorize(
               policy_set,
               entities,
               principal,
               action,
               resource,
               context_json,
               schema
             ) do
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

  @doc "Like `authorize/4` but returns `%ExCedar.Decision{}` directly and raises on error."
  @spec authorize!(term(), term(), Request.t(), keyword()) :: Decision.t()
  def authorize!(policy_set, entities, %Request{} = req, opts \\ []) do
    Error.unwrap!(authorize(policy_set, entities, req, opts))
  end
end
