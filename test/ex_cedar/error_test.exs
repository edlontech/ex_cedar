defmodule ExCedar.ErrorTest do
  use ExUnit.Case, async: true

  alias ExCedar.Error
  alias ExCedar.Error.{Parse, Schema, Entities, Request, Context, TemplateLink, Native}

  @member_errors [
    %Parse{errors: [%{message: "unexpected token", span: nil}], source: "permit("},
    %Schema{message: "unknown namespace", details: nil},
    %Entities{message: "duplicate entity uid"},
    %Request{message: "invalid principal type"},
    %Context{message: "context key must be string"},
    %TemplateLink{message: "template slot not found"},
    %Native{message: "nif returned unexpected term"}
  ]

  describe "splode_error?/1" do
    test "returns true for all member error structs" do
      for err <- @member_errors do
        assert Error.splode_error?(err),
               "expected splode_error?/1 to be true for #{inspect(err.__struct__)}"
      end
    end

    test "returns false for non-splode values" do
      refute Error.splode_error?(:foo)
      refute Error.splode_error?("a string")
      refute Error.splode_error?(%{})
    end
  end

  describe "to_class/1" do
    test "wraps invalid errors into a single Invalid class" do
      invalid_errs = [
        %Parse{errors: [%{message: "oops", span: nil}], source: "foo("},
        %Schema{message: "bad schema", details: "line 3"},
        %Entities{message: "bad entity"}
      ]

      result = Error.to_class(invalid_errs)

      assert %ExCedar.Error.Invalid{errors: nested} = result
      assert length(nested) == 3
    end

    test "wraps unknown errors into Unknown class" do
      result = Error.to_class([%Native{message: "crash"}])
      assert %ExCedar.Error.Unknown{errors: [%Native{}]} = result
    end
  end

  describe "message/1 returns non-empty binary" do
    test "Parse summarizes parse errors" do
      err = %Parse{errors: [%{message: "unexpected eof", span: nil}], source: "permit("}
      msg = Parse.message(err)
      assert is_binary(msg) and msg != ""
    end

    test "Parse with multiple errors joins them" do
      err = %Parse{
        errors: [%{message: "err1", span: nil}, %{message: "err2", span: nil}],
        source: nil
      }

      msg = Parse.message(err)
      assert is_binary(msg) and msg != ""
      assert msg =~ "err1"
      assert msg =~ "err2"
    end

    test "Schema message" do
      msg = Schema.message(%Schema{message: "bad schema", details: nil})
      assert is_binary(msg) and msg != ""
    end

    test "Entities message" do
      msg = Entities.message(%Entities{message: "duplicate uid"})
      assert is_binary(msg) and msg != ""
    end

    test "Request message" do
      msg = Request.message(%Request{message: "bad request"})
      assert is_binary(msg) and msg != ""
    end

    test "Context message" do
      msg = Context.message(%Context{message: "bad context"})
      assert is_binary(msg) and msg != ""
    end

    test "TemplateLink message" do
      msg = TemplateLink.message(%TemplateLink{message: "link failed"})
      assert is_binary(msg) and msg != ""
    end

    test "Native message" do
      msg = Native.message(%Native{message: "nif error"})
      assert is_binary(msg) and msg != ""
    end
  end
end
