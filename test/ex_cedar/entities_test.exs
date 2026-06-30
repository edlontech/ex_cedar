defmodule ExCedar.EntitiesTest do
  use ExUnit.Case, async: true

  alias ExCedar.{Entities, Entity, EntityUid, Error}

  @alice %Entity{
    uid: EntityUid.new("User", "alice"),
    attributes: %{"department" => "eng", "level" => 7},
    parents: [EntityUid.new("Group", "admins")]
  }

  @group %Entity{
    uid: EntityUid.new("Group", "admins"),
    attributes: %{},
    parents: []
  }

  describe "from_list/1" do
    test "returns {:ok, ref} for valid entity list" do
      assert {:ok, ref} = Entities.from_list([@alice, @group])
      assert is_reference(ref)
    end

    test "returns {:ok, ref} for empty list" do
      assert {:ok, ref} = Entities.from_list([])
      assert is_reference(ref)
    end
  end

  describe "from_json/1 — binary" do
    test "accepts a valid Cedar entities JSON string" do
      json = ~s|[{"uid":{"type":"User","id":"alice"},"attrs":{},"parents":[]}]|
      assert {:ok, ref} = Entities.from_json(json)
      assert is_reference(ref)
    end

    test "malformed JSON returns {:error, %Error.Invalid{}} with message" do
      assert {:error, %Error.Invalid{errors: [%Error.Entities{message: msg} | _]}} =
               Entities.from_json("not valid json at all")

      assert is_binary(msg) and msg != ""
    end

    test "invalid entity structure returns {:error, %Error.Invalid{}}" do
      assert {:error, %Error.Invalid{errors: [_ | _]}} =
               Entities.from_json(~s|[{"bad": "entity"}]|)
    end
  end

  describe "from_json/1 — list" do
    test "accepts a list of entity maps" do
      entities = [
        %{
          "uid" => %{"type" => "User", "id" => "alice"},
          "attrs" => %{"level" => 7},
          "parents" => [%{"type" => "Group", "id" => "admins"}]
        },
        %{
          "uid" => %{"type" => "Group", "id" => "admins"},
          "attrs" => %{},
          "parents" => []
        }
      ]

      assert {:ok, ref} = Entities.from_json(entities)
      assert is_reference(ref)
    end

    test "accepts empty list" do
      assert {:ok, ref} = Entities.from_json([])
      assert is_reference(ref)
    end
  end
end
