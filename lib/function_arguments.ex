defmodule Interceptor.FunctionArguments do
  alias Interceptor.Utils

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
  def get_args_names_and_new_args_list(
    {_function_name, _metadata, args_list} = _function_hdr, module) do
      args_list
      |> Enum.map(&get_arg_name_and_its_ast(&1, module))
      |> Enum.unzip()
  end

  defp get_arg_name_and_its_ast({:=, _, [_operand_a, _operand_b] = assignment_operands} = arg_full_ast, _module) do
    arg_variable = assignment_operands
    |> Enum.filter(&is_variable(&1))
    |> hd()

    {arg_name, _, _} = arg_variable

    {arg_name, arg_full_ast}
  end

  defp get_arg_name_and_its_ast({:\\, _metadata, [arg_ast, _default_value_ast]} = arg_full_ast, _module) do
    {arg_name, _, _} = arg_ast

    {arg_name, arg_full_ast}
  end

  # in this case, `arg_ast` doesn't contain an assignment, so we are "manually"
  # placing it inside an assignment statement
  defp get_arg_name_and_its_ast({arg_name, _metadata, _context} = arg_ast, module)
    when arg_name in [:<<>>, :{}, :%{}] do
    random_name = Utils.random_atom()
    random_variable = Macro.var(random_name, module)

    # if value_ast represents `{a,b,c}`, the
    # returned assignment (in AST form) will be like
    # `{a,b,c} = random_variable`
    assignment_ast = {:=, [], [arg_ast, random_variable]}

    {random_name, assignment_ast}
  end

  defp get_arg_name_and_its_ast({arg_name, _metadata, _context} = arg_ast, _module)
    when is_atom(arg_name) do
    {arg_name, arg_ast}
  end

  defp get_arg_name_and_its_ast(arg_ast, module) when is_list(arg_ast) do
    random_name = Utils.random_atom()
    random_variable = Macro.var(random_name, module)

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
