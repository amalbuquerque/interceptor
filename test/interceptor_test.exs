defmodule InterceptorTest do
  use ExUnit.Case
  doctest Interceptor

  test "greets the world" do
    assert Interceptor.hello() == :world
  end
end
