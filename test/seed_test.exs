defmodule SeedTest do
  use ExUnit.Case
  doctest Seed

  test "greets the world" do
    assert Seed.hello() == :world
  end
end
