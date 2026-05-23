defmodule QueryEngineTest do
  use ExUnit.Case
  doctest QueryEngine

  test "greets the world" do
    assert QueryEngine.hello() == :world
  end
end
