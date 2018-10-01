defmodule Interceptor do
  @moduledoc """
  The Interceptor library allows you to intercept function calls, by configuring
  the interception functions and using the `Interceptor.intercept/1` macro.

  Create a module with a `get/0` function that returns the interception
  configuration map.

  ```
  defmodule Interception.Config do
    def get, do: %{
      {Intercepted, :abc, 1} => [
        before: {MyInterceptor, :intercept_before},
        after: {MyInterceptor, :intercept_after}
        on_success: {MyInterceptor, :intercept_on_success},
        on_error: {MyInterceptor, :intercept_on_error},
        # there's also a `wrapper` callback available!
      ]
    }
  end
  ```

  Point to the previous configuration module in your configuration:

  ```
  # [...]
  config :interceptor,
      configuration: Interception.Config
  ```

  Define your interceptor module:

  ```
  defmodule MyInterceptor do
    def intercept_before(mfa),
      do: IO.puts "Intercepted \#\{inspect(mfa)\} before it started."

    def intercept_after(mfa, result),
      do: IO.puts "Intercepted \#\{inspect(mfa)\} after it completed. Its result: \#\{inspect(result)\}"

    def intercept_on_success(mfa, result, _start_timestamp),
      do: IO.puts "Intercepted \#\{inspect(mfa)\} after it completed successfully. Its result: \#\{inspect(result)\}"

    def intercept_on_error(mfa, error, _start_timestamp),
      do: IO.puts "Intercepted \#\{inspect(mfa)\} after it raised an error. Here's the error: \#\{inspect(error)\}"
  end
  ```

  In the module that you want to intercept (in our case, `Intercepted`), place
  the functions that you want to intercept inside a `Interceptor.intercept/1`
  block. If your functions are placed out of this block or if they don't have a
  corresponding interceptor configuration, they won't intercepted. E.g.:

  ```
  defmodule Intercepted do
    require Interceptor, as: I

    I.intercept do
      def abc(x), do: "Got \#\{inspect(x)\}"
    end
  end
  ```

  Now when you run your code, whenever the `Intercepted.abc/1` function is
  called, it will be intercepted *before* it starts and *after* it completes.

  In the previous example, we're defining four callbacks: one `before`, that
  will be called before the intercepted function starts and one `after` that
  will be called after the intercepted function completes. We also define the
  `on_success` and `on_error` callbacks, that will be called when the
  `Intercepted.abc/1` function completes successfully or raises any error,
  respectively.

  If none of the previous callbacks suits your needs, you can use the `wrapper`
  callback. This way, the intercepted function will be wrapped in a lambda and
  passed to your callback function.

  _Note:_ When you use a `wrapper` callback, you can't use any other callback,
  i.e., the `before`, `after`, `on_success` and `on_error` callbacks can't be
  used for a function that is already being intercepted by a `wrapper` callback.
  If you try so, you'll an exception in compile-time will be raised.

  _Note 2:_ When you use the `wrapper` callback, it's the responsibility of the
  callback function to invoke the lambda and return the result. If you don't
  return the result from your callback, the intercepted function return value
  will be whatever value your `wrapper` callback function returns.

  ## Possible callbacks

  * `before` - The callback function that you use to intercept your function
  will be passed the MFA (`{intercepted_module, intercepted_function,
  intercepted_args}`) of the intercepted function, hence it needs to receive
  *one* argument. E.g.:

  ```
  defmodule BeforeInterceptor do
    def called_before_your_function({module, function, args}) do
      ...
    end
  end
  ```

  * `after` - The callback function that you use to intercept your function
  will be passed the MFA (`{intercepted_module, intercepted_function,
  intercepted_args}`) of the intercepted function and its result, hence it needs
  to receive *two* arguments. E.g.:

  ```
  defmodule AfterInterceptor do
    def called_after_your_function({module, function, args}, result) do
      ...
    end
  end
  ```

  * `on_success` - The callback function that you use to intercept your function
  on success will be passed the MFA (`{intercepted_module, intercepted_function,
  intercepted_args}`) of the intercepted function, its success result and the
  start timestamp (in microseconds, obtained with
  `:os.system_time(:microsecond)`), hence it needs to receive *three* arguments.
  E.g.:

  ```
  defmodule SuccessInterceptor do
    def called_when_your_function_completes_successfully(
      {module, function, args}, result, start_timestamp) do
      ...
    end
  end
  ```

  * `on_error` - The callback function that you use to intercept your function
  on error will be passed the MFA (`{intercepted_module, intercepted_function,
  intercepted_args}`) of the intercepted function, the raised error and the
  start timestamp (in microseconds, obtained with
  `:os.system_time(:microsecond)`), hence it needs to receive *three* arguments.
  E.g.:

  ```
  defmodule ErrorInterceptor do
    def called_when_your_function_raises_an_error(
      {module, function, args}, error, start_timestamp) do
      ...
    end
  end
  ```

  * `wrapper` - The callback function that you use to intercept your function
  will be passed the MFA (`{intercepted_module, intercepted_function,
  intercepted_args}`) of the intercepted function and its body wrapped in a
  lambda, hence it needs to receive *two* argument. E.g.:

  ```
  defmodule WrapperInterceptor do
    def called_instead_of_your_function(
      {module, function, args}, intercepted_function_lambda) do
      # do something with the result, or measure how long the lambda call took
      result = intercepted_function_lambda.()

      result
    end
  end
  ```
  """


  @doc """
  Use this macro to wrap all the function definitions of your modules that you
  want to intercept. Remember that you need to configure how the interception
  will work. More information on the `Interceptor` module docs.

  Here's an example of a module that we want to intercept, using the
  `Interceptor.intercept/1` macro:

  ```
  defmodule ModuleToBeIntercepted do
    require Interceptor, as: I

    I.intercept do
      def foo(x), do: "Got \#\{inspect(x)\}"
      def bar, do: "Hi"
      def baz(a, b, c, d), do: a + b + c + d
    end
  end
  ```
  """

  defmacro intercept([do: do_block_body]) do
    updated_do_block = _intercept(__CALLER__.module, do_block_body)

    [do: updated_do_block]
  end

  defp _intercept(caller, {:def, _metadata, _function_hdr_body} = function_def) do
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

    number_args = case args do
      nil -> 0
      args -> length(args)
    end

    {current_module, function, number_args}
  end

  defp add_calls({:def, _metadata, [function_hdr | [[do: function_body]]]} = function, current_module) do
    mfa = get_mfa(current_module, function_hdr)

    function_body = function_body
    |> set_before_callback(mfa)
    |> set_after_callback(mfa)
    |> set_on_success_error_callback(mfa)
    |> set_lambda_wrapper(mfa)

    function
    |> put_elem(2, [function_hdr | [[do: function_body]]])
    |> return_function_body()
  end

  defp add_calls({:defp, _metadata, [_function_hdr | [[do: _function_body]]]} = function, _current_module) do
    function
  end

  defp add_calls(something_else, _current_module) do
    something_else
  end

  defp return_function_body(function_body) do
    config = get_configuration()

    case config && Map.get(config, :debug) do
      true ->
        IO.puts("############# Function AST after interceptor ###")
        IO.inspect(function_body)
      _ -> function_body
    end
  end

  defp set_lambda_wrapper(function_body, mfa) do
    wrapper_function = get_interceptor_module_function_for(mfa, :wrapper)

    wrapper_only_callback? = [
      :before,
      :after,
      :on_success,
      :on_failure
    ] |> Enum.all?(&is_nil(get_interceptor_module_function_for(mfa, &1)))

    set_lambda_wrapper_in_place(function_body, mfa, wrapper_function, wrapper_only_callback?)
  end

  defp set_lambda_wrapper_in_place(function_body, _mfa, nil, _wrapper_only_callback?), do: function_body

  defp set_lambda_wrapper_in_place(_function_body, mfa, _wrapper_function, false),
    do: raise "Wrapper needs to be the only callback configured. You configured another callback besides `wrapper` for the following function: #{inspect(mfa)}."

  defp set_lambda_wrapper_in_place(function_body, mfa, wrapper_function, true),
    do: wrap_block_in_lambda(function_body, mfa, wrapper_function)

  defp set_on_success_error_callback(function_body, mfa) do
    success_callback = get_interceptor_module_function_for(mfa, :on_success)
    error_callback = get_interceptor_module_function_for(mfa, :on_error)

    set_on_success_error_callback_in_place(function_body, mfa, success_callback, error_callback)
  end

  defp set_on_success_error_callback_in_place(function_body, _mfa, nil, nil), do: function_body

  defp set_on_success_error_callback_in_place(function_body, mfa, success_callback, nil),
    do: wrap_do_in_try_catch(function_body, mfa, success_callback, {__MODULE__, :on_error_default_callback})

  defp set_on_success_error_callback_in_place(function_body, mfa, nil, error_callback),
    do: wrap_do_in_try_catch(function_body, mfa, {__MODULE__, :on_success_default_callback}, error_callback)

  defp set_on_success_error_callback_in_place(function_body, mfa, success_callback, error_callback),
    do: wrap_do_in_try_catch(function_body, mfa, success_callback, error_callback)

  defp set_after_callback(function_body, mfa) do
    interceptor_callback = get_interceptor_module_function_for(mfa, :after)

    set_after_callback_in_place(
        function_body, mfa, interceptor_callback)
  end

  defp set_after_callback_in_place(
    function_body, _mfa, nil = _interceptor_callback), do: function_body

  defp set_after_callback_in_place(
    function_body, mfa,
    {interceptor_module, interceptor_function}) do

    new_var_name = :qwertyqwerty
    new_var_not_hygienic = quote do
      var!(unquote(Macro.var(new_var_name, nil)))
    end

    after_quoted_call = quote bind_quoted: [
      interceptor_module: interceptor_module,
      interceptor_function: interceptor_function,
      mfa: Macro.escape(mfa),
      result_var: new_var_not_hygienic
    ] do
      Kernel.apply(interceptor_module, interceptor_function, [mfa, result_var])
    end

    append_to_function_body(function_body, after_quoted_call, new_var_name)
  end

  defp set_before_callback(function_body, mfa) do
    interceptor_callback = get_interceptor_module_function_for(mfa, :before)

    set_before_callback_in_place(
        function_body, mfa, interceptor_callback)
  end

  defp set_before_callback_in_place(
    function_body, _mfa, nil = _interceptor_callback), do: function_body

  defp set_before_callback_in_place(
    function_body, mfa,
    {interceptor_module, interceptor_function}) do

    before_quoted_call = quote bind_quoted: [
      interceptor_module: interceptor_module,
      interceptor_function: interceptor_function,
      mfa: Macro.escape(mfa)
    ] do
      Kernel.apply(interceptor_module, interceptor_function, [mfa])
    end

    prepend_to_function_body(function_body, before_quoted_call)
  end

  defp get_interceptor_module_function_for({_module, _function, _arity} = to_intercept, interception_type) do
    interception_configuration = get_configuration()
    configuration = interception_configuration[to_intercept]

    configuration && Keyword.get(configuration, interception_type)
  end

  defp get_configuration() do
    Application.get_env(:interceptor, :configuration)
    |> config_module_exists?()
    |> get_configuration_from_module()
  end

  defp get_configuration_from_module({false, nil}),
    do: %{}

  defp get_configuration_from_module({false, module}),
    do: raise "Your interceptor configuration is pointing to #{inspect(module)}, an invalid (non-existent?) module. Please check your configuration and try again. The module needs to exist and expose the get/0 function."

  defp get_configuration_from_module({true, module}), do: module.get()

  defp config_module_exists?(module) do
    {ensure_result, _compiled_module} = Code.ensure_compiled(module)
    compiled? = ensure_result == :module

    defines_function? = [__info__: 1, get: 0]
    |> Enum.map(fn {name, arity} -> function_exported?(module, name, arity) end)
    |> Enum.all?(&(&1))

    {compiled? && defines_function?, module}
  end

  defp wrap_block_in_lambda(function_body, {_module, _func, _arity} = mfa, {wrapper_module, wrapper_func}) do
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

  defp wrap_do_in_try_catch(function_body, {module, _func, _arity} = mfa, {success_module, success_func}, {error_module, error_func}) do
    start_time_var_name = :blhargblharg # TODO: Generate randomly
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
    quote do
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

  defp append_to_function_body({:__block__, _metadata, statements}, quoted_call, new_var_name) do
    last_statement = Enum.at(statements, -1)

    {_result_var, new_last_statements} = return_statement_result_after_quoted_call(last_statement, quoted_call, new_var_name)

    new_statements = Enum.take(statements, length(statements) - 1) ++ new_last_statements

    {:__block__, [], new_statements}
  end

  defp append_to_function_body(single_statement, quoted_call, new_var_name) do
    {_result_var, new_last_statements} = return_statement_result_after_quoted_call(single_statement, quoted_call, new_var_name)

    {:__block__, [], new_last_statements}
  end

  defp return_statement_result_after_quoted_call(statement, quoted_call, new_var_name) do
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


  @doc """
  This function will be called as the success callback, in those cases when you
  only define an error callback for your intercepted function.
  """
  def on_success_default_callback(_mfa, _result, _started_at), do: :noop

  @doc """
  This function will be called as the error callback, in those cases when you
  only define a success callback for your intercepted function.
  """
  def on_error_default_callback(_mfa, _error, _started_at), do: :noop
end
