defmodule ExCedar.EntityUidTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  doctest ExCedar.EntityUid

  alias ExCedar.EntityUid

  describe "new/2" do
    test "creates a struct" do
      assert %EntityUid{type: "User", id: "alice"} = EntityUid.new("User", "alice")
    end

    test "accepts namespaced type" do
      assert %EntityUid{type: "App::User", id: "bob"} = EntityUid.new("App::User", "bob")
    end
  end

  describe "to_json/1" do
    test "returns cedar entity-ref json shape" do
      uid = EntityUid.new("User", "alice")
      assert %{"type" => "User", "id" => "alice"} = EntityUid.to_json(uid)
    end

    test "id is raw, unescaped" do
      uid = EntityUid.new("User", ~s|al"ice|)
      assert %{"type" => "User", "id" => ~s|al"ice|} = EntityUid.to_json(uid)
    end
  end

  describe "to_string/1" do
    test "renders simple uid" do
      uid = EntityUid.new("User", "alice")
      assert EntityUid.to_string(uid) == ~s|User::"alice"|
    end

    test "renders namespaced type" do
      uid = EntityUid.new("App::User", "alice")
      assert EntityUid.to_string(uid) == ~s|App::User::"alice"|
    end

    test "escapes double quotes in id" do
      uid = EntityUid.new("User", ~s|al"ice|)
      assert EntityUid.to_string(uid) == ~s|User::"al\\"ice"|
    end

    test "escapes backslashes in id" do
      uid = EntityUid.new("User", "al\\ice")
      assert EntityUid.to_string(uid) == ~s|User::"al\\\\ice"|
    end

    test "escapes backslash then quote in id" do
      uid = EntityUid.new("User", ~s|al\\"ice|)
      assert EntityUid.to_string(uid) == ~s|User::"al\\\\\\"ice"|
    end
  end

  describe "parse/1" do
    test "parses simple uid" do
      assert {:ok, %EntityUid{type: "User", id: "alice"}} = EntityUid.parse(~s|User::"alice"|)
    end

    test "parses namespaced type" do
      assert {:ok, %EntityUid{type: "App::User", id: "alice"}} =
               EntityUid.parse(~s|App::User::"alice"|)
    end

    test "parses id with escaped quotes" do
      assert {:ok, %EntityUid{type: "User", id: ~s|al"ice|}} =
               EntityUid.parse(~s|User::"al\\"ice"|)
    end

    test "parses id with escaped backslashes" do
      assert {:ok, %EntityUid{type: "User", id: "al\\ice"}} =
               EntityUid.parse(~s|User::"al\\\\ice"|)
    end

    test "parses id containing ::" do
      assert {:ok, %EntityUid{type: "User", id: "group::admins"}} =
               EntityUid.parse(~s|User::"group::admins"|)
    end

    test "returns error for missing quotes around id" do
      assert {:error, %ExCedar.Error.Request{}} = EntityUid.parse("User::alice")
    end

    test "returns error for empty string" do
      assert {:error, %ExCedar.Error.Request{}} = EntityUid.parse("")
    end

    test "returns error for bare quoted string without type" do
      assert {:error, %ExCedar.Error.Request{}} = EntityUid.parse(~s|"alice"|)
    end
  end

  property "parse . to_string round-trips for generated uid pairs" do
    check all(
            type <- type_gen(),
            id <- printable_ascii_gen()
          ) do
      uid = EntityUid.new(type, id)
      assert {:ok, ^uid} = EntityUid.parse(EntityUid.to_string(uid))
    end
  end

  defp word_segment do
    chars = Enum.to_list(?a..?z) ++ Enum.to_list(?A..?Z) ++ Enum.to_list(?0..?9) ++ [?_]
    StreamData.string(chars, min_length: 1)
  end

  defp type_gen do
    StreamData.list_of(word_segment(), min_length: 1)
    |> StreamData.map(&Enum.join(&1, "::"))
  end

  defp printable_ascii_gen do
    StreamData.string(Enum.to_list(32..126), min_length: 0)
  end
end
