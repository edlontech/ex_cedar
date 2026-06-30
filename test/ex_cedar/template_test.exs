defmodule ExCedar.TemplateTest do
  use ExUnit.Case, async: true

  alias ExCedar.{Authorizer, Entities, EntityUid, Error, PolicySet, Request}

  # Cedar assigns auto-IDs like "policy0" when parsing from text; ?principal marks it as a template
  @template_text "permit(principal == ?principal, action, resource);"
  @template_id "policy0"

  setup do
    {:ok, ps} = PolicySet.compile(@template_text)
    {:ok, ents} = Entities.from_list([])
    %{ps: ps, ents: ents}
  end

  test "template_ids/1 lists the template id", %{ps: ps} do
    assert PolicySet.template_ids(ps) == [@template_id]
  end

  test "policy_ids/1 is empty before linking", %{ps: ps} do
    assert PolicySet.policy_ids(ps) == []
  end

  test "link_template/4 returns a new handle", %{ps: ps} do
    alice = EntityUid.new("User", "alice")

    assert {:ok, linked_ps} =
             PolicySet.link_template(ps, @template_id, "linked1", %{principal: alice})

    assert is_reference(linked_ps)
  end

  test "original handle is unchanged after link_template/4", %{ps: ps} do
    alice = EntityUid.new("User", "alice")
    {:ok, _linked_ps} = PolicySet.link_template(ps, @template_id, "linked1", %{principal: alice})
    assert "linked1" not in PolicySet.policy_ids(ps)
  end

  test "linked handle contains the new policy id", %{ps: ps} do
    alice = EntityUid.new("User", "alice")
    {:ok, linked_ps} = PolicySet.link_template(ps, @template_id, "linked1", %{principal: alice})
    assert "linked1" in PolicySet.policy_ids(linked_ps)
  end

  test "authorization against linked policy set allows matching principal", %{ps: ps, ents: ents} do
    alice = EntityUid.new("User", "alice")

    {:ok, linked_ps} =
      PolicySet.link_template(ps, @template_id, "linked1", %{principal: alice})

    request = %Request{
      principal: alice,
      action: EntityUid.new("Action", "view"),
      resource: EntityUid.new("File", "doc1"),
      context: %{}
    }

    assert {:ok, decision} = Authorizer.authorize(linked_ps, ents, request)
    assert decision.decision == :allow
  end

  test "authorization against original (unlinked) policy set denies", %{ps: ps, ents: ents} do
    alice = EntityUid.new("User", "alice")

    request = %Request{
      principal: alice,
      action: EntityUid.new("Action", "view"),
      resource: EntityUid.new("File", "doc1"),
      context: %{}
    }

    assert {:ok, decision} = Authorizer.authorize(ps, ents, request)
    assert decision.decision == :deny
  end

  test "link_template/4 with missing required slot returns {:error, %Error.Invalid{}}", %{ps: ps} do
    assert {:error, %Error.Invalid{}} =
             PolicySet.link_template(ps, @template_id, "bad_link", %{})
  end

  test "link_template/4 with unknown template returns {:error, %Error.Invalid{}}", %{ps: ps} do
    alice = EntityUid.new("User", "alice")

    assert {:error, %Error.Invalid{}} =
             PolicySet.link_template(ps, "nonexistent", "bad", %{principal: alice})
  end
end
