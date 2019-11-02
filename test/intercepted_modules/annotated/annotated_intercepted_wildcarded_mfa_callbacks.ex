defmodule AnnotatedWildcardedMfa.Callbacks do
  def success_cb({_module, _function, _args} = mfa, result, started_at) do
    Agent.update(:annotated_wildcarded_mfa_test_process,
      fn messages ->
        [{started_at, Interceptor.Utils.timestamp(), result, mfa} | messages]
      end)
  end

  def error_cb({_module, _function, _args} = mfa, result, started_at) do
    Agent.update(:annotated_wildcarded_mfa_test_process,
      fn messages ->
        [{started_at, Interceptor.Utils.timestamp(), result, mfa} | messages]
      end)
  end
end

defmodule AnnotatedInterceptedWildcardedMfa1 do
  use Interceptor.Annotated

  @intercept true
  def foo(abc), do: "x #{abc} x"

  @intercept true
  def foo(abc, xyz), do: "y #{abc} #{xyz} y"

  @intercept true
  def foo(abc, xyz, qqq, www, eee), do: "z #{abc} #{xyz} #{qqq} #{www} #{eee} z"

  def foo_nop(abc, zzz) do
      abc <> "###" <> zzz
  end
end

defmodule AnnotatedInterceptedWildcardedMfa2 do
  use Interceptor.Annotated

  @intercept true
  def xyz(123), do: "It's a 123"

  @intercept true
  def xyz(wut), do: "It's a #{inspect(wut)}"

  @intercept true
  def foo(abc), do: "x #{abc} x"

  @intercept true
  def foo(abc, xyz), do: "y #{abc} #{xyz} y"

  @intercept true
  def foo(abc, xyz, qqq, www, eee), do: "z #{abc} #{xyz} #{qqq} #{www} #{eee} z"

  @intercept true
  def foo_yes(abc, zzz) do
    abc <> "###" <> zzz
  end

  @intercept true
  def simple_foo() do
    "simple foo"
  end

  @intercept true
  def weird_function_weird_name_big_name("blade:" <> runner_name), do: "I'm a Blade runner named '#{runner_name}'"
end
