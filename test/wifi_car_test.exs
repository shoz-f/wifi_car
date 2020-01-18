defmodule WifiCarTest do
  use ExUnit.Case
  doctest WifiCar

  test "greets the world" do
    assert WifiCar.hello() == :world
  end
end
