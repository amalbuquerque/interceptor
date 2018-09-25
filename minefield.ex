defmodule Outsider do
  # used when we want to intercept *before* the function starts
  def on_before({module, function, arity} = mfa) do
    IO.puts("BEFORE #{inspect(mfa)}")
    42
  end

  # used when we want to intercept *after* the function completes
  def on_after({module, function, arity} = mfa, result) do
    IO.puts("AFTER #{inspect(mfa)}")
    IO.puts("AFTER #{inspect(result)}")
    42
  end

  def on_success(mfa, result, started_at_microseconds \\ nil) do
    time_it_took = case started_at_microseconds do
      nil -> "I don't know"
      _ -> :os.system_time(:microsecond) - started_at_microseconds
    end

    IO.puts("IT WORKED #{inspect(mfa)}, took #{time_it_took} light-years. Here's the result #{inspect(result)}")
  end

  def on_error(mfa, error, started_at_microseconds \\ nil) do
    time_it_took = case started_at_microseconds do
      nil -> "I don't know"
      _ -> :os.system_time(:microsecond) - started_at_microseconds
    end

    IO.puts("IT failed miserably #{inspect(mfa)}, took #{time_it_took} light-years. Here's the error #{inspect(error)}")
  end

  def wrapper(mfa, lambda) do
    result = lambda.()
    IO.puts("[#{inspect(mfa)}] INSIDE wrapper #{inspect(result)}")
    result
  end
end

defmodule Intercept do
  defmacro me([do: {_block, _metadata, definitions} = do_block]) do
    updated_do_block = definitions
                       |> Enum.map(&(add_calls(&1, __CALLER__.module)))
                      |> update_block_definitions(do_block)

    [do: updated_do_block]
  end

  defp get_mfa(current_module, function_header) do
    {function, _context, args} = function_header
    {current_module, function, length(args)}
  end

  defp add_calls({:def, _metadata, [function_hdr | [[do: function_body]]]} = function, current_module) do
    mfa = get_mfa(current_module, function_hdr)

    # BEFORE CALL
    # before_quoted_call = quote bind_quoted: [mfa: Macro.escape(mfa)] do
    #   Kernel.apply(Outsider, :on_before, [mfa])
    # end
    # new_function_body = prepend_to_function_body(function_body, before_quoted_call)

    # AFTER CALL
    # new_var_name = :qwertyqwerty
    # new_var_not_hygienic = quote do
    #   var!(unquote(Macro.var(new_var_name, nil)))
    # end
    # after_quoted_call = quote bind_quoted: [mfa: Macro.escape(mfa), result_var: new_var_not_hygienic] do
    #   Kernel.apply(Outsider, :on_after, [mfa, result_var])
    # end
    # new_function_body = append_to_function_body(function_body, after_quoted_call, new_var_name)

    # ON SUCCESS ON ERROR CALL
    # new_function_body = wrap_do_in_try_catch(function_body, mfa, {Outsider, :on_success}, {Outsider, :on_error})

    # WRAPPER CALL
    new_function_body = wrap_block_in_lambda(function_body, mfa, {Outsider, :wrapper})

    new_function = function
    |> put_elem(2, [function_hdr | [[do: new_function_body]]])

    IO.puts("##################### RESULT")
    IO.inspect(new_function)
  end

  defp add_calls({:defp, _metadata, [function_hdr | [[do: function_body]]]} = function, _current_module) do
    function
  end

  defp add_calls(something_else, _current_module) do
    something_else
  end

  def wrap_block_in_lambda(function_body, {_module, _func, _arity} = mfa, {wrapper_module, wrapper_func}) do
    escaped_mfa = Macro.escape(mfa)
    lambda_wrapped = quote do
      fn ->
        unquote(function_body)
      end
    end

    quote do
      Kernel.apply(unquote(wrapper_module), unquote(wrapper_func), [unquote(escaped_mfa), unquote(lambda_wrapped)])
    end
  end

  def wrap_do_in_try_catch(function_body, {module, _func, _arity} = mfa, {success_module, success_func}, {error_module, error_func}) do
    start_time_var_name = :blhargblharg # TODO: Generate randomly
    # start_time_assignment = quote do
    #   var!(unquote(Macro.var(start_time_var_name, module))) = :os.system_time(:microsecond)
    # end
    # function_body = prepend_to_function_body(function_body, start_time_assignment)

    result_var_name = :abcdefghi # TODO: Generate randomly
    # TODO: Horrible hack, try to use the suggested way
    # by Valim https://groups.google.com/forum/#!topic/elixir-lang-talk/maki_LbLLVI
    new_var_not_hygienic = quote do
      var!(unquote(Macro.var(result_var_name, module)))
    end

    time_var_not_hygienic = quote do
      var!(unquote(Macro.var(start_time_var_name, module)))
    end

    # append the success call to end of the function body
    quoted_success_call = quote bind_quoted: [
      success_module: success_module,
      success_func: success_func,
      mfa: Macro.escape(mfa),
      result_var: new_var_not_hygienic,
      time_var: time_var_not_hygienic
    ] do
      Kernel.apply(success_module, success_func, [mfa, result_var, time_var])
    end
    new_function_body = append_to_function_body(function_body, quoted_success_call, result_var_name)

    escaped_mfa = Macro.escape(mfa)
    try_catch_block = quote do
      unquote(time_var_not_hygienic) = :os.system_time(:microsecond)
      try do
        unquote(new_function_body)
      rescue
        error ->
          Kernel.apply(unquote(error_module), unquote(error_func), [unquote(escaped_mfa), error, unquote(time_var_not_hygienic)])
          reraise(error, __STACKTRACE__)
      end
    end
  end

  defp prepend_to_function_body({:__block__, _metadata, statements} = body, quoted_call) do
    body
    |> put_elem(2, [quoted_call | statements])
  end

  defp prepend_to_function_body(single_statement, quoted_call) do
    {:__block__, [], [quoted_call, single_statement]}
  end

  defp append_to_function_body(body, quoted_call, new_var_name \\ nil)
  defp append_to_function_body({:__block__, _metadata, statements} = body, quoted_call, new_var_name) do
    last_statement = Enum.at(statements, -1)

    {_result_var, new_last_statements} = return_statement_result_after_quoted_call(last_statement, quoted_call, new_var_name)

    new_statements = Enum.take(statements, length(statements) - 1) ++ new_last_statements

    {:__block__, [], new_statements}
  end

  defp append_to_function_body(single_statement, quoted_call, new_var_name) do
    {_result_var, new_last_statements} = return_statement_result_after_quoted_call(single_statement, quoted_call, new_var_name)

    {:__block__, [], new_last_statements}
  end

  defp return_statement_result_after_quoted_call(statement, quoted_call, new_var_name \\ nil) do
    new_result_var = case new_var_name do
      nil -> :qwerty # TODO: Randomly generate this
      _ -> new_var_name
    end

    {
      new_result_var,
      [ # first we store the statement result
        {:=, [],
        [
          {new_result_var, [], nil},
          statement,
        ]},
        # then we call the interceptor function
        quoted_call,
        # finally we return the result
        {new_result_var, [], nil}
      ]
    }
  end

  defp update_block_definitions(new_definitions, {_block, _metadata, _definitions} = do_block) do
    do_block
    |> put_elem(2, new_definitions)
  end
end

defmodule Foo do
  require Intercept

  Intercept.me do
    def abc(x) do
      IO.puts("Hey abc #{x}")
      IO.puts("second entry")
      ccc = 33
      |> Kernel.+(2)
      |> Kernel.-(12)
      ccc
    end

    def err(x) do
      IO.puts("inside err")
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
