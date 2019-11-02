defmodule Interceptor.UtilsTest do
  use ExUnit.Case

  @subject Interceptor.Utils

  describe "random_atom/1" do
    test "it returns an atom of the passed size" do
      result = @subject.random_atom(42)

      assert result |> to_string() |> String.length() == 42
      assert is_atom(result)
    end
  end

  describe "random_string/1" do
    test "it returns a string of the passed size" do
      result = @subject.random_string(42)

      assert String.length(result) == 42
      assert is_binary(result)
    end
  end

  describe "get_mfa_from_string/1" do
    test "it returns the MFA of a simple module" do
      assert {TheCoolModule, :func, 0} == @subject.get_mfa_from_string("TheCoolModule.func/0")
    end

    test "it returns the MFA of a module that belongs to a big namespace" do
      assert {Zi.Zo.Mananananana.Foo.Bar.Qaz.Zac.Bla, :func, 0} == @subject.get_mfa_from_string("Zi.Zo.Mananananana.Foo.Bar.Qaz.Zac.Bla.func/0")
    end

    test "it raises an error when the string isn't valid" do
      assert_raise RuntimeError, fn ->
        @subject.get_mfa_from_string("oh no bad string")
      end
    end

    test "it raises an error when the MFA isn't valid" do
      assert_raise RuntimeError, fn ->
        @subject.get_mfa_from_string({:bla, 123, :blu, 456})
      end
    end

    test "it returns the MFA of an existing function" do
      {module, func, arity} = @subject.get_mfa_from_string("Enum.member?/2")

      assert {Enum, :member?, 2} == {module, func, arity}
      assert function_exported?(module, func, arity)
    end
  end

  describe "get_intercepted_mfa_from_string/1" do
    test "it returns the MFA of a string with wildcarded arity" do
      assert {Bla.Blu, :func, :*} == @subject.get_intercepted_mfa_from_string("Bla.Blu.func/*")
    end

    test "it returns the MFA of a string with wildcarded function and arity" do
      assert {Bla.Blu, :*, :*} == @subject.get_intercepted_mfa_from_string("Bla.Blu.*/*")
    end

    test "it returns the exact same MFA of a tuple with wildcarded arity" do
      assert {Bla.Blu, :func, :*} == @subject.get_intercepted_mfa_from_string({Bla.Blu, :func, :*})
    end

    test "it returns the exact same MFA of a tuple with wildcarded function and arity" do
      assert {Bla.Blu, :*, :*} == @subject.get_intercepted_mfa_from_string({Bla.Blu, :*, :*})
    end

    test "it raises an error when the string isn't valid" do
      assert_raise RuntimeError, fn ->
        @subject.get_intercepted_mfa_from_string("oh no bad string")
      end
    end

    test "it raises an error when the MFA isn't valid" do
      assert_raise RuntimeError, fn ->
        @subject.get_intercepted_mfa_from_string({:bla, 123, :blu, 456})
      end
    end
  end
end
