defmodule ExCedar.Error.Schema do
  @moduledoc false

  use Splode.Error, fields: [:message, :details], class: :invalid

  def message(%{message: msg, details: details}) when is_binary(msg) and is_binary(details) do
    "#{msg}: #{details}"
  end

  def message(%{message: msg}) when is_binary(msg), do: msg

  def message(_), do: "schema error"
end
