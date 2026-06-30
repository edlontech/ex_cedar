defmodule ExCedar.Error.Native do
  @moduledoc false

  use Splode.Error, fields: [:message], class: :unknown

  def message(%{message: msg}) when is_binary(msg), do: msg
  def message(_), do: "unexpected native error"
end
