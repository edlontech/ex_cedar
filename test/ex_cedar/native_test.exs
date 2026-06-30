defmodule ExCedar.NativeTest do
  use ExUnit.Case, async: true

  test "cedar_version/0 returns a semver string" do
    assert ExCedar.Native.cedar_version() =~ ~r/^\d+\.\d+\.\d+/
  end
end
