defmodule ExCedar.Entity do
  @moduledoc false

  alias ExCedar.{EntityUid, Value}

  defstruct [:uid, attributes: %{}, parents: []]

  @type t :: %__MODULE__{
          uid: EntityUid.t(),
          attributes: map(),
          parents: [EntityUid.t()]
        }

  @spec to_json(t()) :: map()
  def to_json(%__MODULE__{uid: uid, attributes: attributes, parents: parents}) do
    %{
      "uid" => EntityUid.to_json(uid),
      "attrs" => Value.encode(attributes),
      "parents" => Enum.map(parents, &EntityUid.to_json/1)
    }
  end
end
