defmodule ExCedar.TelemetryTest do
  use ExUnit.Case, async: true

  alias ExCedar.{Decision, Entities, EntityUid, PolicySet, Request}

  @permit_policy ~s|permit(principal == User::"alice", action == Action::"view", resource == Document::"doc1");|

  @alice_request %Request{
    principal: EntityUid.new("User", "alice"),
    action: EntityUid.new("Action", "view"),
    resource: EntityUid.new("Document", "doc1"),
    context: %{}
  }

  setup do
    {:ok, ps} = PolicySet.compile(@permit_policy)
    {:ok, ents} = Entities.from_list([])
    %{ps: ps, ents: ents}
  end

  describe "[:ex_cedar, :authorize]" do
    test "emits :start and :stop with decision metadata on success", %{ps: ps, ents: ents} do
      ref =
        :telemetry_test.attach_event_handlers(self(), [
          [:ex_cedar, :authorize, :start],
          [:ex_cedar, :authorize, :stop]
        ])

      assert {:ok, %Decision{decision: :allow}} =
               ExCedar.Authorizer.authorize(ps, ents, @alice_request)

      assert_received {[:ex_cedar, :authorize, :start], ^ref,
                       %{monotonic_time: _, system_time: _}, %{}}

      assert_received {[:ex_cedar, :authorize, :stop], ^ref, %{duration: _, monotonic_time: _},
                       %{decision: :allow, determining_policy_count: determining_policy_count}}

      assert is_integer(determining_policy_count) and determining_policy_count >= 1
    end

    test "emits :stop with error: true on {:error, _}", %{ps: ps, ents: ents} do
      ref =
        :telemetry_test.attach_event_handlers(self(), [
          [:ex_cedar, :authorize, :start],
          [:ex_cedar, :authorize, :stop]
        ])

      bad_req = %Request{
        principal: %EntityUid{type: "bad type with spaces", id: "x"},
        action: EntityUid.new("Action", "view"),
        resource: EntityUid.new("Document", "doc1"),
        context: %{}
      }

      assert {:error, _} = ExCedar.Authorizer.authorize(ps, ents, bad_req)

      assert_received {[:ex_cedar, :authorize, :start], ^ref, %{monotonic_time: _}, %{}}

      assert_received {[:ex_cedar, :authorize, :stop], ^ref, %{duration: _, monotonic_time: _},
                       %{error: true}}
    end

    test "emits :exception when the span function raises", %{ents: ents} do
      ref = :telemetry_test.attach_event_handlers(self(), [[:ex_cedar, :authorize, :exception]])

      try do
        ExCedar.Authorizer.authorize(:not_a_handle, ents, @alice_request)
      rescue
        _ -> :ok
      catch
        _, _ -> :ok
      end

      assert_received {[:ex_cedar, :authorize, :exception], ^ref,
                       %{duration: _, monotonic_time: _}, %{kind: _, reason: _, stacktrace: _}}
    end
  end

  describe "[:ex_cedar, :compile]" do
    test "emits :start and :stop on successful compile" do
      ref =
        :telemetry_test.attach_event_handlers(self(), [
          [:ex_cedar, :compile, :start],
          [:ex_cedar, :compile, :stop]
        ])

      assert {:ok, _} = PolicySet.compile(@permit_policy)

      assert_received {[:ex_cedar, :compile, :start], ^ref, %{monotonic_time: _, system_time: _},
                       %{}}

      assert_received {[:ex_cedar, :compile, :stop], ^ref, %{duration: _, monotonic_time: _}, %{}}
    end

    test "emits :start and :stop on compile error" do
      ref =
        :telemetry_test.attach_event_handlers(self(), [
          [:ex_cedar, :compile, :start],
          [:ex_cedar, :compile, :stop]
        ])

      assert {:error, _} = PolicySet.compile("not a policy")

      assert_received {[:ex_cedar, :compile, :start], ^ref, %{monotonic_time: _}, %{}}

      assert_received {[:ex_cedar, :compile, :stop], ^ref, %{duration: _, monotonic_time: _}, %{}}
    end
  end
end
