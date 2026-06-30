defmodule ExCedar.EntityTest do
  use ExUnit.Case, async: true

  alias ExCedar.{Decimal, Entity, EntityUid, IpAddr}

  describe "to_json/1 — minimal entity" do
    test "uid encoded as bare type/id map" do
      entity = %Entity{uid: EntityUid.new("User", "alice")}

      assert %{
               "uid" => %{"type" => "User", "id" => "alice"},
               "attrs" => %{},
               "parents" => []
             } = Entity.to_json(entity)
    end
  end

  describe "to_json/1 — attributes" do
    test "primitive attrs encoded as Cedar record" do
      entity = %Entity{
        uid: EntityUid.new("User", "alice"),
        attributes: %{"department" => "eng", "level" => 7, "active" => true}
      }

      %{"attrs" => attrs} = Entity.to_json(entity)

      assert %{"department" => "eng", "level" => 7, "active" => true} = attrs
    end

    test "nested map in attrs" do
      entity = %Entity{
        uid: EntityUid.new("User", "alice"),
        attributes: %{"meta" => %{"region" => "us-east"}}
      }

      %{"attrs" => attrs} = Entity.to_json(entity)
      assert %{"meta" => %{"region" => "us-east"}} = attrs
    end

    test "entity-ref value in attrs" do
      uid = EntityUid.new("Group", "admins")

      entity = %Entity{
        uid: EntityUid.new("User", "alice"),
        attributes: %{"owner" => uid}
      }

      %{"attrs" => attrs} = Entity.to_json(entity)
      assert %{"owner" => %{"__entity" => %{"type" => "Group", "id" => "admins"}}} = attrs
    end

    test "decimal value in attrs" do
      entity = %Entity{
        uid: EntityUid.new("Item", "x"),
        attributes: %{"price" => Decimal.new("9.99")}
      }

      %{"attrs" => attrs} = Entity.to_json(entity)
      assert %{"price" => %{"__extn" => %{"fn" => "decimal", "arg" => "9.99"}}} = attrs
    end

    test "ip extension value in attrs" do
      entity = %Entity{
        uid: EntityUid.new("Device", "d1"),
        attributes: %{"ip" => IpAddr.new("192.168.0.1")}
      }

      %{"attrs" => attrs} = Entity.to_json(entity)
      assert %{"ip" => %{"__extn" => %{"fn" => "ip", "arg" => "192.168.0.1"}}} = attrs
    end
  end

  describe "to_json/1 — parents" do
    test "parents encoded as list of bare type/id maps" do
      entity = %Entity{
        uid: EntityUid.new("User", "alice"),
        parents: [EntityUid.new("Group", "admins"), EntityUid.new("Group", "users")]
      }

      %{"parents" => parents} = Entity.to_json(entity)

      assert [
               %{"type" => "Group", "id" => "admins"},
               %{"type" => "Group", "id" => "users"}
             ] = parents
    end

    test "parents do NOT use __entity wrapper" do
      entity = %Entity{
        uid: EntityUid.new("User", "bob"),
        parents: [EntityUid.new("Org", "acme")]
      }

      %{"parents" => [parent]} = Entity.to_json(entity)
      refute Map.has_key?(parent, "__entity")
      assert %{"type" => "Org", "id" => "acme"} = parent
    end
  end

  describe "to_json/1 — full entity" do
    test "uid + attrs including nested/entity-ref/decimal + parents" do
      group_uid = EntityUid.new("Group", "admins")

      entity = %Entity{
        uid: EntityUid.new("User", "alice"),
        attributes: %{
          "department" => "eng",
          "level" => 7,
          "group" => group_uid,
          "salary" => Decimal.new("100000.00"),
          "tags" => ["admin", "ops"]
        },
        parents: [EntityUid.new("Group", "admins"), EntityUid.new("Org", "acme")]
      }

      result = Entity.to_json(entity)

      assert %{
               "uid" => %{"type" => "User", "id" => "alice"},
               "attrs" => %{
                 "department" => "eng",
                 "level" => 7,
                 "group" => %{"__entity" => %{"type" => "Group", "id" => "admins"}},
                 "salary" => %{"__extn" => %{"fn" => "decimal", "arg" => "100000.00"}},
                 "tags" => ["admin", "ops"]
               },
               "parents" => [
                 %{"type" => "Group", "id" => "admins"},
                 %{"type" => "Org", "id" => "acme"}
               ]
             } = result
    end
  end
end
