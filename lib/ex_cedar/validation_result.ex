defmodule ExCedar.ValidationResult do
  @moduledoc false

  defmodule Finding do
    @moduledoc false
    defstruct [:policy_id, :message]
  end

  defstruct validated?: false, errors: [], warnings: []
end
