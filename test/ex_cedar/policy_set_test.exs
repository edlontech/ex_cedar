defmodule ExCedar.PolicySetTest do
  use ExUnit.Case, async: true

  doctest ExCedar.PolicySet

  alias ExCedar.PolicySet

  @valid_policy "permit(principal, action, resource);"

  test "compile/1 returns {:ok, ref} for valid policy" do
    assert {:ok, ref} = PolicySet.compile(@valid_policy)
    assert is_reference(ref)
  end

  test "compile/1 returns {:error, %ExCedar.Error.Invalid{}} for invalid policy" do
    assert {:error, %ExCedar.Error.Invalid{errors: [_ | _]}} = PolicySet.compile("not a policy")
  end

  test "compile/1 error contains a Cedar parse message" do
    {:error, %ExCedar.Error.Invalid{errors: errors}} = PolicySet.compile("not a policy")
    assert [%ExCedar.Error.Parse{errors: [%{message: msg} | _]} | _] = errors
    assert is_binary(msg) and msg != ""
  end

  test "compile!/1 returns ref for valid policy" do
    ref = PolicySet.compile!(@valid_policy)
    assert is_reference(ref)
  end

  test "compile!/1 raises for invalid policy" do
    assert_raise ExCedar.Error.Invalid, fn ->
      PolicySet.compile!("not a policy")
    end
  end

  @tag :tmp_dir
  test "from_file/1 round-trips via a temp file", %{tmp_dir: tmp_dir} do
    path = Path.join(tmp_dir, "test.cedar")
    File.write!(path, @valid_policy)
    assert {:ok, ref} = PolicySet.from_file(path)
    assert is_reference(ref)
  end
end
