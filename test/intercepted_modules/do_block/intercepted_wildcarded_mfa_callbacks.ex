defmodule WildcardedMfa.Callbacks do
  def success_cb({_module, _function, _args} = mfa, result, started_at) do
    Agent.update(:wildcarded_mfa_test_process,
      fn messages ->
        [{started_at, Interceptor.Utils.timestamp(), result, mfa} | messages]
      end)
  end

  def error_cb({_module, _function, _args} = mfa, result, started_at) do
    Agent.update(:wildcarded_mfa_test_process,
      fn messages ->
        [{started_at, Interceptor.Utils.timestamp(), result, mfa} | messages]
      end)
  end
end

defmodule InterceptedWildcardedMfa1 do
  require Interceptor, as: I

  I.intercept do
    def foo(abc), do: "x #{abc} x"

    def foo(abc, xyz), do: "y #{abc} #{xyz} y"

    def foo(abc, xyz, qqq, www, eee), do: "z #{abc} #{xyz} #{qqq} #{www} #{eee} z"

    def foo_nop(abc, zzz) do
      abc <> "###" <> zzz
    end
  end
end

defmodule InterceptedWildcardedMfa2 do
  require Interceptor, as: I

  I.intercept do
    def xyz(123), do: "It's a 123"

    def xyz(wut), do: "It's a #{inspect(wut)}"

    def foo(abc), do: "x #{abc} x"

    def foo(abc, xyz), do: "y #{abc} #{xyz} y"

    def foo(abc, xyz, qqq, www, eee), do: "z #{abc} #{xyz} #{qqq} #{www} #{eee} z"

    def foo_yes(abc, zzz) do
      abc <> "###" <> zzz
    end

    def simple_foo() do
      "simple foo"
    end

    def weird_function_weird_name_big_name("blade:" <> runner_name), do: "I'm a Blade runner named '#{runner_name}'"
  end
end
