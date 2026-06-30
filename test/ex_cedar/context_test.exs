defmodule ExCedar.ContextTest do
  use ExUnit.Case, async: true

  alias ExCedar.Context

  describe "from_map/1" do
    test "wraps map in a Context struct" do
      ctx = Context.from_map(%{"mfa" => true})
      assert %Context{attributes: %{"mfa" => true}} = ctx
    end

    test "empty map" do
      ctx = Context.from_map(%{})
      assert %Context{attributes: %{}} = ctx
    end
  end

  describe "to_json/1" do
    test "encodes attributes as Cedar record" do
      ctx = %Context{attributes: %{"mfa" => true, "level" => 3}}
      assert %{"mfa" => true, "level" => 3} = Context.to_json(ctx)
    end

    test "empty context encodes to empty map" do
      assert %{} == Context.to_json(%Context{})
    end

    test "from_map then to_json round-trip" do
      result = %{"ip" => "10.0.0.1"} |> Context.from_map() |> Context.to_json()
      assert %{"ip" => "10.0.0.1"} = result
    end
  end
end
