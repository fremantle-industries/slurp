defmodule SlurpTest do
  use ExUnit.Case
  doctest Slurp

  test "greets the world" do
    assert Slurp.hello() == :world
  end
end
