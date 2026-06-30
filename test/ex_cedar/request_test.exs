defmodule ExCedar.RequestTest do
  use ExUnit.Case, async: true

  alias ExCedar.{Context, EntityUid, Request}

  defp uid(type, id), do: EntityUid.new(type, id)

  describe "Context.from_map/1" do
    test "wraps map in a Context struct" do
      ctx = Context.from_map(%{"mfa" => true})
      assert %Context{attributes: %{"mfa" => true}} = ctx
    end

    test "empty map" do
      ctx = Context.from_map(%{})
      assert %Context{attributes: %{}} = ctx
    end
  end

  describe "Context.to_json/1" do
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

  describe "Request.to_parts/1 — with Context struct" do
    test "returns 4-tuple with correct shapes" do
      request = %Request{
        principal: uid("User", "alice"),
        action: uid("Action", "view"),
        resource: uid("Document", "doc1"),
        context: Context.from_map(%{"mfa" => true})
      }

      {principal, action, resource, context} = Request.to_parts(request)

      assert %{"type" => "User", "id" => "alice"} = principal
      assert %{"type" => "Action", "id" => "view"} = action
      assert %{"type" => "Document", "id" => "doc1"} = resource
      assert %{"mfa" => true} = context
    end

    test "empty Context struct yields empty record" do
      request = %Request{
        principal: uid("User", "u"),
        action: uid("Action", "a"),
        resource: uid("Res", "r"),
        context: %Context{}
      }

      {_, _, _, context} = Request.to_parts(request)
      assert context == %{}
    end
  end

  describe "Request.to_parts/1 — with plain map context" do
    test "plain map context is encoded via Value.encode" do
      request = %Request{
        principal: uid("User", "bob"),
        action: uid("Action", "delete"),
        resource: uid("File", "f1"),
        context: %{"role" => "admin", "count" => 5}
      }

      {principal, action, resource, context} = Request.to_parts(request)

      assert %{"type" => "User", "id" => "bob"} = principal
      assert %{"type" => "Action", "id" => "delete"} = action
      assert %{"type" => "File", "id" => "f1"} = resource
      assert %{"role" => "admin", "count" => 5} = context
    end

    test "empty plain map context yields empty record" do
      request = %Request{
        principal: uid("User", "u"),
        action: uid("Action", "a"),
        resource: uid("Res", "r"),
        context: %{}
      }

      {_, _, _, context} = Request.to_parts(request)
      assert context == %{}
    end
  end

  describe "Request.to_parts/1 — uid shapes" do
    test "UIDs are bare type/id maps, not __entity wrapped" do
      request = %Request{
        principal: uid("User", "alice"),
        action: uid("Action", "view"),
        resource: uid("Document", "doc1")
      }

      {principal, action, resource, _context} = Request.to_parts(request)

      refute Map.has_key?(principal, "__entity")
      refute Map.has_key?(action, "__entity")
      refute Map.has_key?(resource, "__entity")
    end

    test "namespaced type preserved in uid" do
      request = %Request{
        principal: uid("App::User", "carol"),
        action: uid("App::Action", "write"),
        resource: uid("App::Resource", "res42")
      }

      {principal, action, resource, _} = Request.to_parts(request)

      assert %{"type" => "App::User", "id" => "carol"} = principal
      assert %{"type" => "App::Action", "id" => "write"} = action
      assert %{"type" => "App::Resource", "id" => "res42"} = resource
    end
  end
end
