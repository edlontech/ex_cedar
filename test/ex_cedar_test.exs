defmodule ExCedarTest do
  use ExUnit.Case

  alias ExCedar.{Decision, EntityUid, Request}

  @permit_policy """
  permit(principal == User::"alice", action == Action::"view", resource == Document::"doc1");
  """

  @request %Request{
    principal: EntityUid.new("User", "alice"),
    action: EntityUid.new("Action", "view"),
    resource: EntityUid.new("Document", "doc1"),
    context: %{}
  }

  describe "ExCedar.authorize/4 (facade)" do
    test "permit policy yields allow with determining policy" do
      assert {:ok, %Decision{decision: :allow, determining_policies: [_ | _]}} =
               ExCedar.authorize(@permit_policy, [], @request)
    end

    test "no matching permit yields deny" do
      no_match = %Request{
        principal: EntityUid.new("User", "bob"),
        action: EntityUid.new("Action", "view"),
        resource: EntityUid.new("Document", "doc1"),
        context: %{}
      }

      assert {:ok, %Decision{decision: :deny, determining_policies: []}} =
               ExCedar.authorize(@permit_policy, [], no_match)
    end

    test "works without precompiling handles" do
      assert {:ok, %Decision{}} = ExCedar.authorize(@permit_policy, [], @request)
    end

    test "returns error on invalid policy text" do
      assert {:error, _} = ExCedar.authorize("not a policy", [], @request)
    end

    test "per-policy evaluation errors surface in Decision.errors" do
      policy = ~s|permit(principal, action, resource) when { principal.missing == 1 };|

      alice = %ExCedar.Entity{uid: EntityUid.new("User", "alice")}

      assert {:ok, %Decision{decision: :deny, errors: [_ | _]}} =
               ExCedar.authorize(policy, [alice], @request)
    end
  end

  describe "ExCedar.Authorizer.authorize/4" do
    test "authorize!/4 returns Decision on success" do
      {:ok, ps} = ExCedar.PolicySet.compile(@permit_policy)
      {:ok, ents} = ExCedar.Entities.from_list([])

      assert %Decision{decision: :allow} =
               ExCedar.Authorizer.authorize!(ps, ents, @request)
    end

    test "authorize!/4 raises on bad principal uid" do
      {:ok, ps} = ExCedar.PolicySet.compile(@permit_policy)
      {:ok, ents} = ExCedar.Entities.from_list([])

      bad_req = %Request{
        principal: %EntityUid{type: "bad type with spaces", id: "x"},
        action: EntityUid.new("Action", "view"),
        resource: EntityUid.new("Document", "doc1"),
        context: %{}
      }

      assert_raise ExCedar.Error.Invalid, fn ->
        ExCedar.Authorizer.authorize!(ps, ents, bad_req)
      end
    end
  end
end
