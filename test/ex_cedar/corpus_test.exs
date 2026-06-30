defmodule ExCedar.CorpusTest do
  use ExUnit.Case, async: true

  alias ExCedar.{Authorizer, Decision, Entities, EntityUid, PolicySet, Request}

  @fixtures_dir Path.expand("../fixtures/authz", __DIR__)

  for filename <-
        @fixtures_dir
        |> File.ls!()
        |> Enum.filter(&String.ends_with?(&1, ".json"))
        |> Enum.sort() do
    path = Path.join(@fixtures_dir, filename)
    @external_resource path
    fixture = :json.decode(File.read!(path))

    @tag fixture: fixture
    test fixture["description"], %{fixture: fixture} do
      run_fixture(fixture)
    end
  end

  defp run_fixture(fixture) do
    %{
      "policies" => policies,
      "entities" => entities,
      "request" => req,
      "expected" => expected
    } = fixture

    {:ok, principal} = EntityUid.parse(req["principal"])
    {:ok, action} = EntityUid.parse(req["action"])
    {:ok, resource} = EntityUid.parse(req["resource"])

    request = %Request{
      principal: principal,
      action: action,
      resource: resource,
      context: req["context"]
    }

    {:ok, ps} = PolicySet.compile(policies)
    {:ok, ents} = Entities.from_json(entities)
    {:ok, %Decision{} = decision} = Authorizer.authorize(ps, ents, request)

    assert decision.decision == String.to_atom(expected["decision"])

    assert MapSet.new(decision.determining_policies) ==
             MapSet.new(expected["determining_policies"])

    if expected["has_errors"] do
      assert decision.errors != []
    end
  end
end
