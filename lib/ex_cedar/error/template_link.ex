defmodule ExCedar.Error.TemplateLink do
  @moduledoc false

  use Splode.Error, fields: [:message], class: :invalid

  def message(%{message: msg}) when is_binary(msg), do: msg
  def message(_), do: "template link error"
end
