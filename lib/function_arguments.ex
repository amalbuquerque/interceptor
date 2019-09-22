defmodule Interceptor.FunctionArguments do
  alias Interceptor.Utils

  @ignored_value :arg_cant_be_intercepted

  @doc """
  Use this function to get a tuple containing a list with the names
  of the function arguments and the list of the arguments in AST form.

  For the function `def abcd(a, b, c), do: 123` you would get:

  ```
  {
    [:a, :b, :c],
    [{:a, [], Elixir}, {:b, [], Elixir}, {:c, [], Elixir}]
  }
  ```

  For a function with one or more "anonymous" arguments, this function
  will assign each argument like this to a random variable.

  For the function `def foo(x, y, {bar}), do: 42` it would return:

  ```
  {
    [:x, :y, :a1b2c3d],
    [
      {:x, [], Elixir},
      {:y, [], Elixir},
      {:=, [], [{:{}, [], [{:bar, [], Elixir}]}, {:a1b2c3d, [], Elixir}]}
    ]
  }
  ```

  Notice the last assignment to the `a1b2c3d` random variable, returning
  the argument list in AST form as if the
  the function was defined like `def foo(x, y, {bar} = a1b2c3d), do: 42`.
  """
  # functions with no arguments have nil as their `args_list`
  def get_args_names_and_new_args_list({_function_name, _metadata, nil} = _function_hdr), do: {[], nil}

  def get_args_names_and_new_args_list(
    {_function_name, _metadata, args_list} = _function_hdr) do
      args_list
      |> Enum.map(&get_arg_name_and_its_ast(&1))
      |> Enum.unzip()
  end

  def get_actual_function_header(
    {:when, _guard_metadata, [
      {_function_name, _metadata, _args_list} = function_hdr | _guard_clauses
    ]}), do: function_hdr

  def get_actual_function_header(
    {_function_name, _metadata, _args_list} = function_hdr), do: function_hdr

  def get_function_header_with_new_args_names(
    {:when, guard_metadata, [
      {function_name, metadata, _args_list} = function_hdr | guard_clauses
    ]}) do

    {args_names, new_args_list} = get_args_names_and_new_args_list(function_hdr)

    new_function_header = {:when, guard_metadata, [
      {function_name, metadata, new_args_list} | guard_clauses
    ]}

    {new_function_header, args_names}
  end

  def get_function_header_with_new_args_names(
    {function_name, metadata, _args_list} = function_hdr) do
    {args_names, new_args_list} = get_args_names_and_new_args_list(function_hdr)

    new_function_header = {function_name, metadata, new_args_list}
    {new_function_header, args_names}
  end

  @doc """
  Returns the AST that gets us the value of each argument, so we can pass
  the intercepted function argument values to the callback.

  If the `arg_name` starts with `_`, it means it isn't used in the intercepted
  function body, hence we shouldn't access its value to pass it to the callback
  function, passing instead the @ignored_value.

  TODO: receive the current module and pass it as context
  """
  def get_not_hygienic_args_values_ast(nil), do: []

  def get_not_hygienic_args_values_ast(args_names) do
    args_names
    |> Enum.map(&to_string/1)
    |> Enum.map(fn
      "_" <> _arg_name -> @ignored_value
      arg_name ->
        arg_name = String.to_atom(arg_name)

        quote do: var!(unquote(Macro.var(arg_name, nil)))
    end)
  end

  # previously we were using Macro.escape for the mfa (arity),
  # but we now want the args values not to be quoted,
  # because they are already quoted
  def escape_module_function_but_not_args({module, function, args})
  when is_atom(module) and is_atom(function) and is_list(args) do
    {
      :{},
      [],
      [
        module,
        function,
        args
      ]
    }
  end

  defp get_arg_name_and_its_ast({:=, _, [_operand_a, _operand_b] = assignment_operands} = arg_full_ast) do
    arg_variable = assignment_operands
    |> Enum.filter(&is_variable(&1))
    |> hd()

    {arg_name, _, _} = arg_variable

    {arg_name, arg_full_ast}
  end

  defp get_arg_name_and_its_ast({:\\, _metadata, [arg_ast, _default_value_ast]} = arg_full_ast) do
    {arg_name, _, _} = arg_ast

    {arg_name, arg_full_ast}
  end

  # in this case, `arg_ast` doesn't contain an assignment, so we are "manually"
  # placing it inside an assignment statement
  defp get_arg_name_and_its_ast({arg_name, _metadata, _context} = arg_ast)
  when arg_name in [:<<>>, :{}, :%{}, :%, :<>] do
    random_name = Utils.random_atom()

    # arg variables always have their context as nil
    random_variable = Macro.var(random_name, nil)

    # if value_ast represents `{a,b,c}`, the
    # returned assignment (in AST form) will be like
    # `{a,b,c} = random_variable`
    assignment_ast = {:=, [], [arg_ast, random_variable]}

    {random_name, assignment_ast}
  end

  defp get_arg_name_and_its_ast({arg_name, _metadata, _context} = arg_ast)
    when is_atom(arg_name) do
    {arg_name, arg_ast}
  end

  defp get_arg_name_and_its_ast(arg_ast) when is_list(arg_ast) or is_tuple(arg_ast) or is_integer(arg_ast) or is_binary(arg_ast) do
    random_name = Utils.random_atom()
    #
    # arg variables always have their context as nil
    random_variable = Macro.var(random_name, nil)

    # if value_ast represents `[a,b,c]`, the
    # returned assignment (in AST form) will be like
    # `[a,b,c] = random_variable`
    assignment_ast = {:=, [], [arg_ast, random_variable]}

    {random_name, assignment_ast}
  end

  defp is_variable({name, metadata, context})
    when is_atom(name) and is_list(metadata) and is_atom(context), do: true

  defp is_variable(_other_ast), do: false
end
