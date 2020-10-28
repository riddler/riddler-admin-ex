defmodule RiddlerAgentTest do
  use ExUnit.Case
  doctest RiddlerAgent

  test "greets the world" do
    assert RiddlerAgent.hello() == :world
  end
end
