defmodule ExCedar.Entity do
  @moduledoc """
  Cedar entity — a uid, a map of attributes, and a list of parent UIDs.

  Build entity structs and pass a list of them to `ExCedar.Entities.from_list/1`.

      %ExCedar.Entity{
        uid: ExCedar.EntityUid.new("User", "alice"),
        attributes: %{"department" => "eng", "level" => 7},
        parents: [ExCedar.EntityUid.new("Group", "admins")]
      }

  Attribute values follow Cedar's JSON value encoding rules (booleans, integers,
  strings, lists as sets, maps as records, entity references, and extension
  values like `ExCedar.Decimal` and `ExCedar.IpAddr`).
  """

  alias ExCedar.{EntityUid, Value}

  defstruct [:uid, attributes: %{}, parents: []]

  @type t :: %__MODULE__{
          uid: EntityUid.t(),
          attributes: map(),
          parents: [EntityUid.t()]
        }

  @doc "Encodes the entity as a Cedar entities JSON object."
  @spec to_json(t()) :: map()
  def to_json(%__MODULE__{uid: uid, attributes: attributes, parents: parents}) do
    %{
      "uid" => EntityUid.to_json(uid),
      "attrs" => Value.encode(attributes),
      "parents" => Enum.map(parents, &EntityUid.to_json/1)
    }
  end
end
