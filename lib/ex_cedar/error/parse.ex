defmodule ExCedar.Error.Parse do
  @moduledoc false

  use Splode.Error, fields: [:errors, :source], class: :invalid

  def message(%{errors: errors}) when is_list(errors) and errors != [] do
    Enum.map_join(errors, "; ", fn e -> e[:message] end)
  end

  def message(_), do: "policy parse failed"
end
