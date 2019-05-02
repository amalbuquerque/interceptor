defmodule Interceptor do
  @moduledoc """
  The Interceptor library allows you to intercept function calls, by configuring
  your interception functions and using the `Interceptor.intercept/1` macro.

  Create a module with a `get_intercept_config/0` function that returns the
  interception configuration map.

  In the example below, the `Intercepted.abc/1` function will be intercepted
  *before* it starts, *after* it ends, and when it concludes successfully or not:

  ```
  defmodule Interception.Config do
    def get_intercept_config, do: %{
      {Intercepted, :abc, 1} => [
        before: {MyInterceptor, :intercept_before, 1},
        after: {MyInterceptor, :intercept_after, 2},
        on_success: {MyInterceptor, :intercept_on_success, 3},
        on_error: {MyInterceptor, :intercept_on_error, 3}
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

  Define the callback functions that will be called during the execution of your intercepted functions:

  ```
  defmodule MyInterceptor do
    def intercept_before(mfargs),
      do: IO.puts "Intercepted \#\{inspect(mfargs)\} before it started."

    def intercept_after(mfargs, result),
      do: IO.puts "Intercepted \#\{inspect(mfargs)\} after it completed. Its result: \#\{inspect(result)\}"

    def intercept_on_success(mfargs, result, _start_timestamp),
      do: IO.puts "Intercepted \#\{inspect(mfargs)\} after it completed successfully. Its result: \#\{inspect(result)\}"

    def intercept_on_error(mfargs, error, _start_timestamp),
      do: IO.puts "Intercepted \#\{inspect(mfargs)\} after it raised an error. Here's the error: \#\{inspect(error)\}"
  end
  ```

  Finally, wrap the functions to intercept with an `Interceptor.intercept/1` block
  (`Interceptor.intercept/1` is actually a macro). Notice that if your functions
  are placed outside of this block or if they don't have a corresponding interceptor
  configuration, they won't be intercepted.

  This is how the `Intercepted` module using the `intercept/1` macro looks like:

  ```
  defmodule Intercepted do
    require Interceptor, as: I

    I.intercept do
      def abc(x), do: "Got \#\{inspect(x)\}"
    end

    # the following function can't be intercepted
    # because it isn't enclosed in the `Interceptor.intercept/1` block
    def not_intercepted(f, g, h), do: f+g+h
  end
  ```

  In the previous example, we defined four callbacks:

  - a `before` callback, that will be called before the intercepted function starts;
  - an `after` callback, that will be called after the intercepted function completes;
  - an `on_success` callback, that will be called if the function completes successfully;
  - an `on_error` callback, that will be called if the function raises any error.

  Now when you run your code, whenever the `Intercepted.abc/1` function is
  called, it will be intercepted *before* it starts, *after* it completes,
  when it completes *successfully* or when it *raises* an error.

  You can also intercept private functions in the exact same way you intercept
  public functions. You just need to configure the callbacks that should be invoked for
  the given private function, and the private function definition needs to be enclosed in
  an `Interceptor.intercept/1` macro.

  ### MFA passed to your callbacks

  Every function callback that you define will receive as its first argument a "MFArgs"
  tuple, i.e., `{intercepted_module, intercepted_function, intercepted_args}`.
  The `intercepted_args` is a list of arguments passed to your intercepted function.
  Even if your intercepted function only receives a single argument, `intercepted_args`
  will still be a list with a single element.

  *Pro-tip*: Since your callback function receives the arguments that the intercepted
  function received, you can pattern match on the argument values function. ⚠️  Just
  have in mind that if your `intercepted_args` don't pattern match the values your
  callback function expects, you'll get an error every time your callback function
  does its thing and intercepts the function.

  ### Wrapper callback (aka build your custom callback)

  If none of the previous callbacks suits your needs, you can use the `wrapper`
  callback. This way, the intercepted function will be wrapped in a lambda and
  passed to your callback function.

  When you use a `wrapper` callback, you can't use any other callback,
  i.e., the `before`, `after`, `on_success` and `on_error` callbacks can't be
  used for a function that is already being intercepted by a `wrapper` callback.
  If you try so, an exception in compile-time will be raised.

  When you use the `wrapper` callback, it's the responsibility of the
  callback function to invoke the lambda and return the result. If you don't
  return the result from your callback, the return value of the intercepted
  function will be whatever value your `wrapper` callback function returns.

  ## Possible callbacks

  * `before` - The callback function that you use to intercept your function
  will be passed the MFArgs (`{intercepted_module, intercepted_function,
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
  will be passed the MFArgs (`{intercepted_module, intercepted_function,
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
  on success will be passed the MFArgs (`{intercepted_module, intercepted_function,
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
  on error will be passed the MFArgs (`{intercepted_module, intercepted_function,
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
  will be passed the MFArgs (`{intercepted_module, intercepted_function,
  intercepted_args}`) of the intercepted function and its body wrapped in a
  lambda, hence it needs to receive *two* arguments. E.g.:

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

  ## Streamlined configuration

  If you think that defining a `get_intercept_config/0` function on the configuration
  module or using the `{module, function, arity}` format is too verbose, you can use the
  `Interceptor.Configurator` module that will allow you to use its `intercept/2` macro
  and the `"Module.function/arity"` streamlined format.

  Using the `Configurator` and the new streamlined format, the previous configuration
  for the `Intercepted.abc/1` function would become:

  ```
  defmodule Interception.Config do
    use Interceptor.Configurator

    intercept "Intercepted.abc/1",
      before: "MyInterceptor.intercept_before/1",
      after: "MyInterceptor.intercept_after/2"
      on_success: "MyInterceptor.intercept_on_success/3",
      on_error: "MyInterceptor.intercept_on_error/3"
      # there's also a `wrapper` callback available!

    intercept "OtherModule.another_function/2",
      on_success: "OtherInterceptor.success_callback/3"

    # ...
  end
  ```

  The `Configurator` module is defining the needed `get_intercept_config/0` function for you,
  and converting those string MFAs into tuple-based MFAs. If you want to intercept another
  function, it's just a matter of adding other `intercept
  "OtherModule.another_function/2", ...` entry, exactly as we did.

  ## Intercept configuration on the intercepted module

  If you don't want to place the intercept configuration on the application configuration
  file, you can set it directly on the intercepted module, just add `use Interceptor,
  config: <config_module>`, instead of requiring the `Interceptor` module. Using the
  previous `Intercepted` module as an example:

  ```
  defmodule Intercepted do
    use Interceptor, config: Interception.Config

    Interceptor.intercept do
      def abc(x), do: "Got \#\{inspect(x)\}"
    end

    def not_intercepted(f, g, h), do: f+g+h
  end
  ```

  _Note1:_ If the configuration you set on the intercepted module overlaps with a
  configuration set on the application configuration file, the former will take
  precedence, i.e., if both the intercepted module configuration and the application
  configuration set the rules to intercept the `Intercepted.abc/1` function, the
  rules set on the intercepted module will prevail, overriding the rules set on
  the application configuration file.

  Instead of pointing to the intercept configuration module, you may also pass the
  intercept configuration directly via the `config` keyword. E.g:

  ```
  defmodule Intercepted do
    use Interceptor, config: %{
      "Intercepted.abc/1" => [
        before: "MyInterceptor.intercept_before/1",
        after: "MyInterceptor.intercept_after/2"
      ]
    }

    Interceptor.intercept do
      def abc(x), do: "Got \#\{inspect(x)\}"
    end

    def not_intercepted(f, g, h), do: f+g+h
  end
  ```

  Notice that we're using the streamlined format for the MFAs, but we could also use the
  more verbose tuple-based MFAs.
  """

  alias Interceptor.Utils
  import Interceptor.Configuration
  import Interceptor.FunctionArguments

  @before_callback_arity 1
  @after_callback_arity 2
  @on_success_callback_arity 3
  @on_error_callback_arity 3
  @wrapper_callback_arity 2

  defmacro __using__(opts) do
    own_config = Keyword.get(opts, :config)
    {own_config_module, _bindings} = Code.eval_quoted(own_config)
    Module.put_attribute(__CALLER__.module, :own_config, own_config_module)

    quote do
      require unquote(__MODULE__)
    end
  end

  @doc """
  Use this macro to wrap all the function definitions of your modules that you
  want to intercept. Remember that you need to configure how the interception

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

  defp _intercept(caller, {:def, _metadata, _function_hdr_body} = function_def),
    do: _intercept(caller, {:__block__, [], [function_def]})

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

  defp get_mfargs(current_module, function_header, args_names) do
    {current_module, current_function, _arity} = get_mfa(current_module, function_header)

    args_values = get_not_hygienic_args_values_ast(args_names)

    {current_module, current_function, args_values}
  end

  defp add_calls({type, _metadata, [function_hdr | [[do: function_body]]]} = function, current_module) when type in [:def, :defp] do
    {new_function_hdr, args_names} = get_function_header_with_new_args_names(function_hdr)
    mfargs = get_mfargs(current_module, function_hdr, args_names)

    new_function_body = function_body
    |> set_before_callback(mfargs)
    |> set_after_callback(mfargs)
    |> set_on_success_error_callback(mfargs)
    |> set_lambda_wrapper(mfargs)

    function
    |> put_elem(2, [new_function_hdr | [[do: new_function_body]]])
    |> return_function_body()
  end

  defp add_calls(something_else, _current_module) do
    something_else
  end

  defp return_function_body(function_body) do
    case debug_mode?() do
      true ->
        IO.puts("############# Function AST after interceptor ###")
        IO.inspect(function_body, limit: :infinity)
      _ -> function_body
    end
  end

  defp set_lambda_wrapper(function_body, mfargs) do
    wrapper_function = get_interceptor_module_function_for(mfargs, :wrapper)

    wrapper_only_callback? = [
      :before,
      :after,
      :on_success,
      :on_failure
    ] |> Enum.all?(&is_nil(get_interceptor_module_function_for(mfargs, &1)))

    set_lambda_wrapper_in_place(function_body, mfargs, wrapper_function, wrapper_only_callback?)
  end

  defp set_lambda_wrapper_in_place(function_body, _mfargs, nil, _wrapper_only_callback?), do: function_body

  defp set_lambda_wrapper_in_place(_function_body, mfargs, _wrapper_function, false),
    do: raise "Wrapper needs to be the only callback configured. You configured another callback besides `wrapper` for the following function: #{inspect(mfargs)}."

  defp set_lambda_wrapper_in_place(function_body, mfargs, wrapper_function, true),
    do: wrap_block_in_lambda(function_body, mfargs, wrapper_function)

  defp set_on_success_error_callback(function_body, mfargs) do
    success_callback = get_interceptor_module_function_for(mfargs, :on_success)
    error_callback = get_interceptor_module_function_for(mfargs, :on_error)

    set_on_success_error_callback_in_place(function_body, mfargs, success_callback, error_callback)
  end

  defp set_on_success_error_callback_in_place(function_body, _mfargs, nil, nil), do: function_body

  defp set_on_success_error_callback_in_place(function_body, mfargs, success_callback, nil),
    do: wrap_do_in_try_catch(function_body, mfargs, success_callback, {__MODULE__, :on_error_default_callback, @on_error_callback_arity})

  defp set_on_success_error_callback_in_place(function_body, mfargs, nil, error_callback),
    do: wrap_do_in_try_catch(function_body, mfargs, {__MODULE__, :on_success_default_callback, @on_success_callback_arity}, error_callback)

  defp set_on_success_error_callback_in_place(function_body, mfargs, success_callback, error_callback),
    do: wrap_do_in_try_catch(function_body, mfargs, success_callback, error_callback)

  defp set_after_callback(function_body, mfargs) do
    interceptor_callback = get_interceptor_module_function_for(mfargs, :after)

    set_after_callback_in_place(
        function_body, mfargs, interceptor_callback)
  end

  defp set_after_callback_in_place(
    function_body, _mfargs, nil = _interceptor_callback), do: function_body

  defp set_after_callback_in_place(
    function_body, {module, _function, _arguments} = mfargs,
    {interceptor_module, interceptor_function, @after_callback_arity}) do

    {result_var_name, result_var_not_hygienic} = random_quoted_not_higienic_var(module)

    after_quoted_call = quote bind_quoted: [
      interceptor_module: interceptor_module,
      interceptor_function: interceptor_function,
      mfargs: escape_module_function_but_not_args(mfargs),
      result_var: result_var_not_hygienic
    ] do
      Kernel.apply(interceptor_module, interceptor_function, [mfargs, result_var])
    end

    append_to_function_body(function_body, after_quoted_call, result_var_name)
  end

  defp set_before_callback(function_body, mfargs) do
    interceptor_callback = get_interceptor_module_function_for(mfargs, :before)

    set_before_callback_in_place(
        function_body, mfargs, interceptor_callback)
  end

  defp set_before_callback_in_place(
    function_body, _mfargs, nil = _interceptor_callback), do: function_body

  defp set_before_callback_in_place(
    function_body, mfargs,
    {interceptor_module, interceptor_function, @before_callback_arity}) do

    before_quoted_call = quote bind_quoted: [
      interceptor_module: interceptor_module,
      interceptor_function: interceptor_function,
      mfargs: escape_module_function_but_not_args(mfargs)
    ] do
      Kernel.apply(interceptor_module, interceptor_function, [mfargs])
    end

    prepend_to_function_body(function_body, before_quoted_call)
  end

  defp wrap_block_in_lambda(function_body,
    {_module, _func, _args} = mfargs,
    {wrapper_module, wrapper_func, @wrapper_callback_arity}) do
    escaped_mfargs = escape_module_function_but_not_args(mfargs)
    lambda_wrapped = quote do
      fn ->
        unquote(function_body)
      end
    end

    quote do
      Kernel.apply(unquote(wrapper_module), unquote(wrapper_func), [unquote(escaped_mfargs), unquote(lambda_wrapped)])
    end
  end

  defp wrap_do_in_try_catch(function_body, {module, _func, _args} = mfargs,
    {success_module, success_func, @on_success_callback_arity},
    {error_module, error_func, @on_error_callback_arity}) do
    {result_var_name, result_var_not_hygienic} = random_quoted_not_higienic_var(module)
    {_start_time_var_name, time_var_not_hygienic} = random_quoted_not_higienic_var(module)

    escaped_mfargs = escape_module_function_but_not_args(mfargs)
    # append the success call to end of the function body
    quoted_success_call = quote bind_quoted: [
      success_module: success_module,
      success_func: success_func,
      mfargs: escaped_mfargs,
      result_var: result_var_not_hygienic,
      time_var: time_var_not_hygienic
    ] do
      Kernel.apply(success_module, success_func, [mfargs, result_var, time_var])
    end
    new_function_body = append_to_function_body(function_body, quoted_success_call, result_var_name)

    quote do
      unquote(time_var_not_hygienic) = :os.system_time(:microsecond)
      try do
        unquote(new_function_body)
      rescue
        error ->
          Kernel.apply(unquote(error_module), unquote(error_func), [unquote(escaped_mfargs), error, unquote(time_var_not_hygienic)])
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
    {
      new_var_name,
      [ # first we store the statement result
        {:=, [],
        [
          {new_var_name, [], nil},
          statement,
        ]},
        # then we call the interceptor function
        quoted_call,
        # finally we return the result
        {new_var_name, [], nil}
      ]
    }
  end

  defp update_block_definitions(new_definitions, {_block, _metadata, _definitions} = do_block) do
    do_block
    |> put_elem(2, new_definitions)
  end

  defp random_quoted_not_higienic_var(module) do
    random_name = Utils.random_atom()

    quoted_var_definition = quote do
      var!(unquote(Macro.var(random_name, module)))
    end

    {random_name, quoted_var_definition}
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
