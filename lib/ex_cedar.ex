defmodule ExCedar do
  @moduledoc """
  Cedar policy engine bindings for Elixir.

  One-shot convenience: compile inputs and evaluate authorization in a single call.
  Use `ExCedar.PolicySet`, `ExCedar.Entities`, and `ExCedar.Authorizer` directly
  when you need to reuse compiled handles across multiple requests.

  ## Example

      iex> policy = "permit(principal, action, resource);"
      iex> request = %ExCedar.Request{
      ...>   principal: ExCedar.EntityUid.new("User", "alice"),
      ...>   action: ExCedar.EntityUid.new("Action", "view"),
      ...>   resource: ExCedar.EntityUid.new("Document", "doc1"),
      ...>   context: %{}
      ...> }
      iex> {:ok, %ExCedar.Decision{decision: :allow}} = ExCedar.authorize(policy, [], request)

  """

  alias ExCedar.{Authorizer, Decision, Entities, PolicySet, Request}

  @spec authorize(String.t(), list(), Request.t(), keyword()) ::
          {:ok, Decision.t()} | {:error, term()}
  def authorize(policy_text, entities, %Request{} = request, opts \\ []) do
    with {:ok, ps} <- PolicySet.compile(policy_text),
         {:ok, ents} <- Entities.from_list(entities) do
      Authorizer.authorize(ps, ents, request, opts)
    end
  end
end
