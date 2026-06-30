defmodule ExCedar.EntityUid do
  @moduledoc false

  defstruct [:type, :id]

  @type t :: %__MODULE__{type: String.t(), id: String.t()}

  # Matches type (greedy, so last :: before quoted id wins) then ::"id"
  @uid_pattern ~r/^(.+)::"((?:[^"\\]|\\.)*)"$/

  def new(type, id), do: %__MODULE__{type: type, id: id}

  def parse(string) do
    case Regex.run(@uid_pattern, string, capture: :all_but_first) do
      [type, raw_id] ->
        {:ok, %__MODULE__{type: type, id: unescape(raw_id)}}

      nil ->
        {:error, %ExCedar.Error.Request{message: "invalid entity uid: #{inspect(string)}"}}
    end
  end

  def to_string(%__MODULE__{type: type, id: id}) do
    type <> "::\"" <> escape(id) <> "\""
  end

  def to_json(%__MODULE__{type: type, id: id}), do: %{"type" => type, "id" => id}

  defp escape(id) do
    id
    |> String.replace("\\", "\\\\")
    |> String.replace("\"", "\\\"")
  end

  defp unescape(raw) do
    Regex.replace(~r/\\(["\\])/, raw, "\\1")
  end
end
