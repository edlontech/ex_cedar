defmodule ExCedar do
  @moduledoc """
  Cedar policy engine bindings for Elixir.

  One-shot convenience: compile inputs and evaluate authorization in a single
  call. Use `ExCedar.PolicySet`, `ExCedar.Entities`, and `ExCedar.Authorizer`
  directly when you need to reuse compiled handles across multiple requests.

  ## Example

      iex> policy = "permit(principal, action, resource);"
      iex> request = %ExCedar.Request{
      ...>   principal: ExCedar.EntityUid.new("User", "alice"),
      ...>   action: ExCedar.EntityUid.new("Action", "view"),
      ...>   resource: ExCedar.EntityUid.new("Document", "doc1"),
      ...>   context: %{}
      ...> }
      iex> {:ok, dec} = ExCedar.authorize(policy, [], request)
      iex> dec.decision
      :allow

  """

  alias ExCedar.{Authorizer, Decision, Entities, PolicySet, Request, Schema}

  @doc """
  Compiles `policy_text` and `entities` on the fly and runs authorization.

  Options:
  - `:schema` — Cedar schema text or a compiled `ExCedar.Schema` handle.
    When supplied, the request is validated against the schema before evaluation.

  Prefer `ExCedar.Authorizer.authorize/4` with pre-compiled handles on hot
  paths to avoid recompiling on every call.
  """
  @spec authorize(String.t(), list(), Request.t(), keyword()) ::
          {:ok, Decision.t()} | {:error, term()}
  def authorize(policy_text, entities, %Request{} = request, opts \\ []) do
    with {:ok, ps} <- PolicySet.compile(policy_text),
         {:ok, ents} <- Entities.from_list(entities),
         {:ok, schema} <- resolve_schema(Keyword.get(opts, :schema)) do
      Authorizer.authorize(ps, ents, request, Keyword.put(opts, :schema, schema))
    end
  end

  defp resolve_schema(nil), do: {:ok, nil}
  defp resolve_schema(ref) when is_reference(ref), do: {:ok, ref}
  defp resolve_schema(text) when is_binary(text), do: Schema.compile(text)
end
