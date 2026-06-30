defmodule ExCedar.SchemaTest do
  use ExUnit.Case, async: true

  alias ExCedar.{Error, Schema}

  @valid_human_schema """
  entity User;
  entity Document;
  action view appliesTo { principal: [User], resource: [Document] };
  """

  @valid_json_schema %{
    "" => %{
      "entityTypes" => %{
        "User" => %{},
        "Document" => %{}
      },
      "actions" => %{
        "view" => %{
          "appliesTo" => %{
            "principalTypes" => ["User"],
            "resourceTypes" => ["Document"]
          }
        }
      }
    }
  }

  describe "compile/1" do
    test "valid human schema returns {:ok, reference}" do
      assert {:ok, ref} = Schema.compile(@valid_human_schema)
      assert is_reference(ref)
    end

    test "invalid schema returns {:error, %Error.Invalid{}}" do
      assert {:error, %Error.Invalid{errors: [%Error.Schema{message: msg}]}} =
               Schema.compile("this is not a valid schema!!!")

      assert is_binary(msg) and msg != ""
    end
  end

  describe "compile!/1" do
    test "returns reference on valid schema" do
      assert is_reference(Schema.compile!(@valid_human_schema))
    end

    test "raises on invalid schema" do
      assert_raise Error.Invalid, fn -> Schema.compile!("not a schema") end
    end
  end

  describe "from_json/1" do
    test "accepts a map and returns {:ok, reference}" do
      assert {:ok, ref} = Schema.from_json(@valid_json_schema)
      assert is_reference(ref)
    end

    test "accepts a JSON binary and returns {:ok, reference}" do
      json = @valid_json_schema |> :json.encode() |> IO.iodata_to_binary()
      assert {:ok, ref} = Schema.from_json(json)
      assert is_reference(ref)
    end

    test "invalid JSON schema returns {:error, %Error.Invalid{}}" do
      assert {:error, %Error.Invalid{errors: [%Error.Schema{message: msg}]}} =
               Schema.from_json("{\"bad\": \"json schema\"}")

      assert is_binary(msg) and msg != ""
    end
  end

  describe "from_json!/1" do
    test "returns reference on valid JSON schema map" do
      assert is_reference(Schema.from_json!(@valid_json_schema))
    end

    test "raises on invalid JSON schema" do
      assert_raise Error.Invalid, fn -> Schema.from_json!("{\"bad\": \"json schema\"}") end
    end
  end
end
