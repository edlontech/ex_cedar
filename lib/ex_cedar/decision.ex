defmodule ExCedar.Decision do
  @moduledoc false

  defstruct [:decision, determining_policies: [], errors: []]

  @type t :: %__MODULE__{
          decision: :allow | :deny,
          determining_policies: [String.t()],
          errors: [String.t()]
        }
end
