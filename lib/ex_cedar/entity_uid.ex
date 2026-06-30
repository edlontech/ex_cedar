defmodule ExCedar.EntityUid do
  @moduledoc """
  Cedar entity UID — a `{type, id}` pair that uniquely identifies an entity.

  The `type` field may be namespaced (e.g. `"App::User"`). The `id` is the
  bare string value (unescaped). Use `to_string/1` to render the Cedar syntax
  `Type::"id"` and `parse/1` to parse it back.
  """

  defstruct [:type, :id]

  @type t :: %__MODULE__{type: String.t(), id: String.t()}

  # Matches type (greedy, so last :: before quoted id wins) then ::"id"
  @uid_pattern ~r/^(.+)::"((?:[^"\\]|\\.)*)"$/

  @doc "Builds an `EntityUid` from `type` and `id` strings."
  def new(type, id), do: %__MODULE__{type: type, id: id}

  @doc """
  Parses a Cedar-syntax entity UID string into an `EntityUid`.

      iex> ExCedar.EntityUid.parse(~s|User::"alice"|)
      {:ok, %ExCedar.EntityUid{type: "User", id: "alice"}}

      iex> {:ok, uid} = ExCedar.EntityUid.parse(~s|App::User::"bob"|)
      iex> uid.type
      "App::User"

  Returns `{:error, %ExCedar.Error.Request{}}` if the string is not a valid
  Cedar entity UID.
  """
  def parse(string) do
    case Regex.run(@uid_pattern, string, capture: :all_but_first) do
      [type, raw_id] ->
        {:ok, %__MODULE__{type: type, id: unescape(raw_id)}}

      nil ->
        {:error, %ExCedar.Error.Request{message: "invalid entity uid: #{inspect(string)}"}}
    end
  end

  @doc """
  Renders the `EntityUid` as a Cedar-syntax string (`Type::"id"`).

  Special characters in `id` (backslash and double-quote) are escaped.
  """
  def to_string(%__MODULE__{type: type, id: id}) do
    type <> "::\"" <> escape(id) <> "\""
  end

  @doc """
  Returns the Cedar JSON entity-reference shape: `%{"type" => type, "id" => id}`.
  """
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
