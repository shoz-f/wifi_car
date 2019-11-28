defmodule RcCarTest do
  use ExUnit.Case
  doctest RcCar

  test "greets the world" do
    assert RcCar.hello() == :world
  end
end
