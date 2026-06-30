defmodule ExCedarTest do
  use ExUnit.Case
  doctest ExCedar

  test "greets the world" do
    assert ExCedar.hello() == :world
  end
end
