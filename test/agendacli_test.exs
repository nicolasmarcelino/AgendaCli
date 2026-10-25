defmodule AgendacliTest do
  use ExUnit.Case
  doctest Agendacli

  test "greets the world" do
    assert Agendacli.hello() == :world
  end
end
