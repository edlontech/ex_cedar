defmodule ExCedar.ValidatorTest do
  use ExUnit.Case, async: true

  alias ExCedar.{Error, PolicySet, Schema, Validator, ValidationResult}
  alias ExCedar.ValidationResult.Finding

  @schema_text """
  entity User;
  entity Document;
  action view appliesTo { principal: [User], resource: [Document] };
  """

  @consistent_policy """
  permit(principal is User, action == Action::"view", resource is Document);
  """

  @inconsistent_policy """
  permit(principal is User, action == Action::"view", resource is Document)
  when { resource.nonExistentAttr == "foo" };
  """

  setup do
    {:ok, ps} = PolicySet.compile(@consistent_policy)
    {:ok, bad_ps} = PolicySet.compile(@inconsistent_policy)
    {:ok, schema} = Schema.compile(@schema_text)
    %{ps: ps, bad_ps: bad_ps, schema: schema}
  end

  describe "validate/3" do
    test "consistent policy validates successfully", %{ps: ps, schema: schema} do
      assert {:ok, %ValidationResult{validated?: true, errors: []}} =
               Validator.validate(ps, schema)
    end

    test "inconsistent policy returns validation findings", %{bad_ps: bad_ps, schema: schema} do
      assert {:ok, %ValidationResult{validated?: false, errors: [%Finding{} | _]}} =
               Validator.validate(bad_ps, schema)
    end

    test "unsupported mode raises", %{ps: ps, schema: schema} do
      assert_raise ArgumentError, fn -> Validator.validate(ps, schema, mode: :permissive) end
    end

    test "bad handle returns {:error, %Error.Invalid{}}", %{schema: schema} do
      assert {:error, %Error.Invalid{}} = Validator.validate(nil, schema)
    end
  end
end
