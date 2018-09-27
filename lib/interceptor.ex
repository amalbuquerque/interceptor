defmodule Interceptor do
  @moduledoc """
  Documentation for Interceptor.
  """

  @doc """
  TODO: Docs for intercept
  """
  defmacro intercept([do: do_block_body]) do
    updated_do_block = _intercept(__CALLER__.module, do_block_body)

    [do: updated_do_block]
  end

  defp _intercept(caller, {:def, _metadata, function_hdr_body} = function_def) do
    _intercept(caller, {:__block__, [], [function_def]})
  end

  defp _intercept(caller, {:__block__, _metadata, definitions} = do_block) do
    definitions
    |> Enum.map(&(add_calls(&1, caller)))
    |> update_block_definitions(do_block)
  end

  defp _intercept(_caller, something_else), do: something_else

  defp get_mfa(current_module, function_header) do
    {function, _context, args} = function_header
    {current_module, function, length(args)}
  end

  defp add_calls({:def, _metadata, [function_hdr | [[do: function_body]]]} = function, current_module) do
    mfa = get_mfa(current_module, function_hdr)

    # BEFORE CALL
    function_body = set_on_before_callback(function_body, mfa)

    # AFTER CALL
    # new_var_name = :qwertyqwerty
    # new_var_not_hygienic = quote do
    #   var!(unquote(Macro.var(new_var_name, nil)))
    # end
    # after_quoted_call = quote bind_quoted: [mfa: Macro.escape(mfa), result_var: new_var_not_hygienic] do
    #   Kernel.apply(Outsider, :on_after, [mfa, result_var])
    # end
    # function_body = append_to_function_body(function_body, after_quoted_call, new_var_name)

    # ON SUCCESS ON ERROR CALL
    # function_body = wrap_do_in_try_catch(function_body, mfa, {Outsider, :on_success}, {Outsider, :on_error})

    # WRAPPER CALL
    # function_body = wrap_block_in_lambda(function_body, mfa, {Outsider, :wrapper})

    new_function = function
    |> put_elem(2, [function_hdr | [[do: function_body]]])

    IO.puts("##################### RESULT")
    IO.inspect(new_function)
  end

  defp add_calls({:defp, _metadata, [function_hdr | [[do: function_body]]]} = function, _current_module) do
    function
  end

  defp add_calls(something_else, _current_module) do
    something_else
  end

  defp set_on_before_callback(function_body, mfa) do
    interceptor_mfa = get_interceptor_mfa_for(mfa, :on_before)

    set_on_before_callback_in_place(
        function_body, mfa, interceptor_mfa)
  end

  defp set_on_before_callback_in_place(
    function_body, mfa, nil = _interceptor_mfa), do: function_body

  defp set_on_before_callback_in_place(
    function_body, mfa,
    {interceptor_module, interceptor_function, _interceptor_arity}) do

    before_quoted_call = quote bind_quoted: [
      interceptor_module: interceptor_module,
      interceptor_function: interceptor_function,
      mfa: Macro.escape(mfa)
    ] do
      Kernel.apply(interceptor_module, interceptor_function, [mfa])
    end

    prepend_to_function_body(function_body, before_quoted_call)
  end

  defp get_interceptor_mfa_for({_module, _function, _arity} = to_intercept, interception_type) do
    interception_configuration = Application.get_env(:interceptor, :configuration)
    configuration = interception_configuration[to_intercept]

    configuration && Keyword.get(configuration, interception_type)
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
