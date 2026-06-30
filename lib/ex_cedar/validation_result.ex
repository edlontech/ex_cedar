defmodule ExCedar.ValidationResult do
  @moduledoc """
  Result of `ExCedar.Validator.validate/3`.

  `validated?` is `true` when `errors` is empty. Warnings may be present even
  when `validated?` is `true`. Both `errors` and `warnings` are lists of
  `ExCedar.ValidationResult.Finding` structs.
  """

  defmodule Finding do
    @moduledoc """
    A single validation finding — one policy-level error or warning.

    - `policy_id` — the Cedar policy ID the finding pertains to.
    - `message` — Cedar's human-readable description of the issue.
    """
    defstruct [:policy_id, :message]

    @type t :: %__MODULE__{policy_id: String.t() | nil, message: String.t() | nil}
  end

  defstruct validated?: false, errors: [], warnings: []

  @type t :: %__MODULE__{
          validated?: boolean(),
          errors: [Finding.t()],
          warnings: [Finding.t()]
        }
end
