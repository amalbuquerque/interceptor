defmodule Outsider do
  # used when we want to intercept *before* the function starts
  def before({_module, _function, _arity} = mfa) do
    IO.puts("BEFORE #{inspect(mfa)}")
    42
  end

  # used when we want to intercept *after* the function completes
  def right_after({_module, _function, _arity} = mfa, result) do
    IO.puts("AFTER #{inspect(mfa)}")
    IO.puts("AFTER #{inspect(result)}")
    42
  end

  def on_success({_module, _function, _arity} = mfa, result, started_at_microseconds \\ nil) do
    time_it_took = case started_at_microseconds do
      nil -> "I don't know"
      _ -> :os.system_time(:microsecond) - started_at_microseconds
    end

    IO.puts("IT WORKED #{inspect(mfa)}, took #{time_it_took} light-years. Here's the result #{inspect(result)}")
  end

  def on_error({_module, _function, _arity} = mfa, error, started_at_microseconds \\ nil) do
    time_it_took = case started_at_microseconds do
      nil -> "I don't know"
      _ -> :os.system_time(:microsecond) - started_at_microseconds
    end

    IO.puts("IT failed miserably #{inspect(mfa)}, took #{time_it_took} light-years. Here's the error #{inspect(error)}")
  end

  def wrapper({_module, _function, _arity} = mfa, lambda) do
    result = lambda.()
    IO.puts("[#{inspect(mfa)}] INSIDE wrapper #{inspect(result)}")
    result
  end
end

defmodule Foo do
  require Interceptor, as: I

  I.intercept do
    def abc(x) do
      IO.puts("Hey abc #{x}")
      IO.puts("second entry")
      ccc = 33
      |> Kernel.+(2)
      |> Kernel.-(12)
      ccc
    end

    def err(x) do
      IO.puts("inside err #{x}")
      4+5
      33/0
      9+8
    end

    def yyy(), do: IO.puts("alo from yyy")
    def zzz(), do: lalalu("From ZZZ")

    defp lalalu(foo), do: "#{foo} Fa #{foo}"
  end

  def xyz(x) do
    IO.puts("Hey xyz #{x}")
  end
end
