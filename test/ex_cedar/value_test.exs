defmodule ExCedar.ValueTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias ExCedar.{Decimal, EntityUid, IpAddr, Value}

  describe "encode/1 — primitives" do
    test "boolean true" do
      assert Value.encode(true) == true
    end

    test "boolean false" do
      assert Value.encode(false) == false
    end

    test "integer" do
      assert Value.encode(42) == 42
    end

    test "negative integer" do
      assert Value.encode(-7) == -7
    end

    test "string" do
      assert Value.encode("hello") == "hello"
    end

    test "empty string" do
      assert Value.encode("") == ""
    end
  end

  describe "encode/1 — sets (lists)" do
    test "empty list" do
      assert Value.encode([]) == []
    end

    test "list of booleans" do
      assert Value.encode([true, false]) == [true, false]
    end

    test "list of integers" do
      assert Value.encode([1, 2, 3]) == [1, 2, 3]
    end

    test "list of strings" do
      assert Value.encode(["a", "b"]) == ["a", "b"]
    end

    test "nested list" do
      assert Value.encode([[1, 2], [3]]) == [[1, 2], [3]]
    end
  end

  describe "encode/1 — records (maps)" do
    test "empty map" do
      assert Value.encode(%{}) == %{}
    end

    test "map with string keys" do
      assert Value.encode(%{"x" => 1, "y" => true}) == %{"x" => 1, "y" => true}
    end

    test "map with atom keys becomes string keys" do
      assert Value.encode(%{role: "admin", active: true}) == %{
               "role" => "admin",
               "active" => true
             }
    end

    test "nested map" do
      assert Value.encode(%{"a" => %{"b" => 42}}) == %{"a" => %{"b" => 42}}
    end

    test "map with list value" do
      assert Value.encode(%{"tags" => ["x", "y"]}) == %{"tags" => ["x", "y"]}
    end

    test "list of maps" do
      input = [%{"k" => 1}, %{"k" => 2}]
      assert Value.encode(input) == [%{"k" => 1}, %{"k" => 2}]
    end

    test "map containing entity uid value" do
      uid = EntityUid.new("Group", "admins")
      encoded = Value.encode(%{"owner" => uid})
      assert %{"owner" => %{"__entity" => %{"type" => "Group", "id" => "admins"}}} = encoded
    end
  end

  describe "encode/1 — entity ref" do
    test "EntityUid wraps to __entity" do
      uid = EntityUid.new("User", "alice")
      assert Value.encode(uid) == %{"__entity" => %{"type" => "User", "id" => "alice"}}
    end

    test "namespaced type is preserved" do
      uid = EntityUid.new("App::User", "bob")
      assert Value.encode(uid) == %{"__entity" => %{"type" => "App::User", "id" => "bob"}}
    end
  end

  describe "encode/1 — decimal extension" do
    test "Decimal produces __extn with fn=decimal" do
      d = Decimal.new("1.5")
      assert Value.encode(d) == %{"__extn" => %{"fn" => "decimal", "arg" => "1.5"}}
    end

    test "negative decimal value" do
      d = Decimal.new("-3.14")
      assert Value.encode(d) == %{"__extn" => %{"fn" => "decimal", "arg" => "-3.14"}}
    end
  end

  describe "encode/1 — ip extension" do
    test "IpAddr produces __extn with fn=ip" do
      ip = IpAddr.new("10.0.0.0/24")
      assert Value.encode(ip) == %{"__extn" => %{"fn" => "ip", "arg" => "10.0.0.0/24"}}
    end

    test "ipv6 address" do
      ip = IpAddr.new("::1")
      assert Value.encode(ip) == %{"__extn" => %{"fn" => "ip", "arg" => "::1"}}
    end
  end

  describe "encode/1 — unsupported types raise" do
    test "float raises ArgumentError" do
      assert_raise ArgumentError, fn -> Value.encode(3.14) end
    end

    test "nil raises ArgumentError" do
      assert_raise ArgumentError, fn -> Value.encode(nil) end
    end

    test "tuple raises ArgumentError" do
      assert_raise ArgumentError, fn -> Value.encode({:ok, 1}) end
    end

    test "atom (other than boolean) raises ArgumentError" do
      assert_raise ArgumentError, fn -> Value.encode(:some_atom) end
    end
  end

  property "encoded output is JSON-encodable and has string map keys" do
    check all(term <- cedar_term_gen()) do
      encoded = Value.encode(term)
      json_binary = IO.iodata_to_binary(:json.encode(encoded))
      assert is_binary(json_binary)
      assert all_string_keys?(encoded)
    end
  end

  defp cedar_term_gen do
    leaf_gen =
      StreamData.one_of([
        StreamData.boolean(),
        StreamData.integer(),
        StreamData.string(:alphanumeric),
        entity_uid_gen(),
        decimal_gen(),
        ip_addr_gen()
      ])

    StreamData.tree(leaf_gen, fn subtree ->
      StreamData.one_of([
        StreamData.list_of(subtree, max_length: 3),
        StreamData.map_of(
          StreamData.string(:alphanumeric, min_length: 1),
          subtree,
          max_length: 3
        )
      ])
    end)
  end

  defp entity_uid_gen do
    gen all(
          type <- StreamData.string(:alphanumeric, min_length: 1),
          id <- StreamData.string(:alphanumeric, min_length: 1)
        ) do
      EntityUid.new(type, id)
    end
  end

  defp decimal_gen do
    gen all(n <- StreamData.integer(-1000..1000)) do
      Decimal.new("#{n}.0")
    end
  end

  defp ip_addr_gen do
    gen all(
          a <- StreamData.integer(0..255),
          b <- StreamData.integer(0..255),
          c <- StreamData.integer(0..255),
          d <- StreamData.integer(0..255)
        ) do
      IpAddr.new("#{a}.#{b}.#{c}.#{d}")
    end
  end

  defp all_string_keys?(v) when is_map(v) do
    Enum.all?(v, fn {k, val} -> is_binary(k) and all_string_keys?(val) end)
  end

  defp all_string_keys?(v) when is_list(v), do: Enum.all?(v, &all_string_keys?/1)
  defp all_string_keys?(_), do: true
end
