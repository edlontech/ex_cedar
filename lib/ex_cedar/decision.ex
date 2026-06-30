defmodule ExCedar.Decision do
  @moduledoc """
  Authorization decision returned by `ExCedar.Authorizer.authorize/4`.

  - `:allow` — at least one permit policy matched and no forbid policy matched.
  - `:deny` — the default when no permit matched, or a forbid policy matched.
  - `determining_policies` — IDs of the policies that caused the outcome.
  - `errors` — per-policy evaluation errors (Cedar runtime errors, e.g.
    attribute access on an entity not in the store). The decision is still
    valid when this list is non-empty.
  """

  defstruct [:decision, determining_policies: [], errors: []]

  @type t :: %__MODULE__{
          decision: :allow | :deny,
          determining_policies: [String.t()],
          errors: [String.t()]
        }
end
