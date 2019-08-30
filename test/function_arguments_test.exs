defmodule FunctionArgumentsTest do
  use ExUnit.Case
  alias Interceptor.FunctionArguments

  describe "gets each argument name and the corresponding value (in AST form)" do
    test "it handles no arguments" do
      function_header = get_function_header("def abc(), do: 123")
      result = FunctionArguments.get_args_names_and_new_args_list(function_header)

      assert {[], []} == result
    end

    test "it handles simple arguments" do
      function_header = get_function_header("def abc(x, y, z), do: x+y+z")
      result = FunctionArguments.get_args_names_and_new_args_list(function_header)

      {args_names, args_ast} = result

      assert args_names == [:x, :y, :z]
      assert length(args_ast) == 3

      expected_args_ast = args_names
                          |> Enum.map(&Macro.var(&1, nil))

      args_ast
      |> Enum.zip(expected_args_ast)
      |> Enum.each(&assert_ast_match(&1))
    end

    test "it handles tuple destructure" do
      function_header = get_function_header("def abc({x, y, z}), do: x+y+z")
      result = FunctionArguments.get_args_names_and_new_args_list(function_header)

      {args_names, args_ast} = result

      assert length(args_names) == length(args_ast)
      assert length(args_ast) == 1

      [{:=, _metadata, [arg_ast, random_var_ast]}] = args_ast

      expected_arg_ast = quote do: {x, y, z}
      expected_random_var_ast = Macro.var(hd(args_names), nil)

      assert_ast_match(arg_ast, expected_arg_ast)
      assert_ast_match(random_var_ast, expected_random_var_ast)
    end

    test "it handles binary destructure" do
      function_header = get_function_header("def abc(<<x, y, z>>), do: [x,y,z]")
      result = FunctionArguments.get_args_names_and_new_args_list(function_header)

      {args_names, args_ast} = result

      assert length(args_names) == length(args_ast)
      assert length(args_ast) == 1

      [{:=, _metadata, [arg_ast, random_var_ast]}] = args_ast

      expected_arg_ast = quote do: <<x, y, z>>
      expected_random_var_ast = Macro.var(hd(args_names), nil)

      assert_ast_match(arg_ast, expected_arg_ast)
      assert_ast_match(random_var_ast, expected_random_var_ast)
    end

    test "it handles map destructure" do
      function_header = get_function_header("def abc(%{a: x, b: y, c: z}), do: [x,y,z]")
      result = FunctionArguments.get_args_names_and_new_args_list(function_header)

      {args_names, args_ast} = result

      assert length(args_names) == length(args_ast)
      assert length(args_ast) == 1

      [{:=, _metadata, [arg_ast, random_var_ast]}] = args_ast

      expected_arg_ast = quote do: %{a: x, b: y, c: z}
      expected_random_var_ast = Macro.var(hd(args_names), nil)

      assert_ast_match(arg_ast, expected_arg_ast)
      assert_ast_match(random_var_ast, expected_random_var_ast)
    end

    test "it handles structure destructure" do
      function_header = get_function_header("def abc(%Media{a: x, b: y, c: z}), do: [x,y,z]")
      result = FunctionArguments.get_args_names_and_new_args_list(function_header)

      {args_names, args_ast} = result

      assert length(args_names) == length(args_ast)
      assert length(args_ast) == 1

      [{:=, _metadata, [arg_ast, random_var_ast]}] = args_ast

      expected_arg_ast = quote do: %Media{a: x, b: y, c: z}
      expected_random_var_ast = Macro.var(hd(args_names), nil)

      assert_ast_match(arg_ast, expected_arg_ast)
      assert_ast_match(random_var_ast, expected_random_var_ast)
    end

    test "it handles keyword list destructure" do
      function_header = get_function_header("def abc([a: x, b: y, c: z]), do: [x,y,z]")
      result = FunctionArguments.get_args_names_and_new_args_list(function_header)

      {args_names, args_ast} = result

      assert length(args_names) == length(args_ast)
      assert length(args_ast) == 1

      [{:=, _metadata, [arg_ast, random_var_ast]}] = args_ast

      expected_arg_ast = quote do: [a: x, b: y, c: z]
      expected_random_var_ast = Macro.var(hd(args_names), nil)

      assert_ast_match(arg_ast, expected_arg_ast)
      assert_ast_match(random_var_ast, expected_random_var_ast)
    end

    test "it handles list destructure (one element)" do
      function_header = get_function_header("def abc([x]), do: [x]")
      result = FunctionArguments.get_args_names_and_new_args_list(function_header)

      {args_names, args_ast} = result

      assert length(args_names) == length(args_ast)
      assert length(args_ast) == 1

      [{:=, _metadata, [arg_ast, random_var_ast]}] = args_ast

      expected_arg_ast = quote do: [x]
      expected_random_var_ast = Macro.var(hd(args_names), nil)

      assert_ast_match(arg_ast, expected_arg_ast)
      assert_ast_match(random_var_ast, expected_random_var_ast)
    end

    test "it handles list destructure (more than one element)" do
      function_header = get_function_header("def abc([x,y,z]), do: [x,y,z]")
      result = FunctionArguments.get_args_names_and_new_args_list(function_header)

      {args_names, args_ast} = result

      assert length(args_names) == length(args_ast)
      assert length(args_ast) == 1

      [{:=, _metadata, [arg_ast, random_var_ast]}] = args_ast

      expected_arg_ast = quote do: [x,y,z]
      expected_random_var_ast = Macro.var(hd(args_names), nil)

      assert_ast_match(arg_ast, expected_arg_ast)
      assert_ast_match(random_var_ast, expected_random_var_ast)
    end

    test "it handles existing assignments (variable first)" do
      function_header = get_function_header("def abc(a = {bar}), do: [a, bar]")
      result = FunctionArguments.get_args_names_and_new_args_list(function_header)

      {args_names, args_ast} = result

      assert args_names == [:a]
      assert length(args_ast) == 1

      expected_arg_ast = quote do: a = {bar}

      assert_ast_match(hd(args_ast), expected_arg_ast)
    end

    test "it handles existing assignments (variable after)" do
      function_header = get_function_header("def abc({bar} = foo), do: [foo, bar]")
      result = FunctionArguments.get_args_names_and_new_args_list(function_header)

      {args_names, args_ast} = result

      assert args_names == [:foo]
      assert length(args_ast) == 1

      expected_arg_ast = quote do: {bar} = foo

      assert_ast_match(hd(args_ast), expected_arg_ast)
    end

    test "it handles default values (nil)" do
      function_header = get_function_header("def abc(foo \\\\ nil), do: [foo]")
      result = FunctionArguments.get_args_names_and_new_args_list(function_header)

      {args_names, args_ast} = result

      assert args_names == [:foo]
      assert length(args_ast) == 1

      expected_arg_ast = quote do: foo \\ nil

      assert_ast_match(hd(args_ast), expected_arg_ast)
    end

    test "it handles default values (123)" do
      function_header = get_function_header("def abc(bar \\\\ 123), do: [bar]")
      result = FunctionArguments.get_args_names_and_new_args_list(function_header)

      {args_names, args_ast} = result

      assert args_names == [:bar]
      assert length(args_ast) == 1

      expected_arg_ast = quote do: bar \\ 123

      assert_ast_match(hd(args_ast), expected_arg_ast)
    end

    test "it handles default values (strings)" do
      function_header = get_function_header("def abc(baz \\\\ \"blabla\"), do: [baz]")
      result = FunctionArguments.get_args_names_and_new_args_list(function_header)

      {args_names, args_ast} = result

      assert args_names == [:baz]
      assert length(args_ast) == 1

      expected_arg_ast = quote do: baz \\ "blabla"

      assert_ast_match(hd(args_ast), expected_arg_ast)
    end
  end

  describe "the function that returns the expression to pass the argument values to the callback function, `get_not_hygienic_args_values_ast/1`" do
    test "returns the expected AST for each function arguments" do
      arg_names = [:a, :b, :c]
      result = FunctionArguments.get_not_hygienic_args_values_ast(arg_names)

      arg_names
      |> Enum.zip(result)
      |> Enum.each(&assert_not_hygienic_arg_value_ast(&1))
    end

    test "returns a default value for each function argument that is ignored (starts with `_`)" do
      arg_names = [:a, :b, :c, :_x, :_y, :d, :e, :_z, :f]
      result = FunctionArguments.get_not_hygienic_args_values_ast(arg_names)

      normal_arguments_and_result = [0, 1, 2, 5, 6, 8]
                                    |> Enum.map(fn indx ->
                                      {Enum.at(arg_names, indx), Enum.at(result, indx)}
                                    end)

      normal_arguments_and_result
      |> Enum.each(&assert_not_hygienic_arg_value_ast(&1))

      ignored_arguments_and_result = [3, 4, 7]
                                    |> Enum.map(fn indx ->
                                      {Enum.at(arg_names, indx), Enum.at(result, indx)}
                                    end)

      ignored_arguments_and_result
      |> Enum.each(fn {name, result} ->
        name = to_string(name)

        assert String.starts_with?(name, "_")
        assert result == :arg_cant_be_intercepted
      end)
    end
  end

  def assert_ast_match({
    {_arg_name, _arg_metadata, _arg_context} = ast,
    {_expected_arg_name, _expected_arg_metadata, _expected_arg_context} = expected
  }), do: assert_ast_match(ast, expected)

  def assert_ast_match(
    {arg_name, _arg_metadata, _arg_context} = ast,
    {expected_arg_name, _expected_arg_metadata, _expected_arg_context} = expected) do
      assert arg_name == expected_arg_name

      assert Macro.to_string(ast) == Macro.to_string(expected)
    end

  def assert_ast_match(ast, expected) when is_list(ast) and is_list(expected) do
      assert Macro.to_string(ast) == Macro.to_string(expected)
  end

  def assert_not_hygienic_arg_value_ast({variable, ast}) when is_atom(variable) and is_tuple(ast) do
    expected = quote context: Interceptor.FunctionArguments, do: var!(unquote(Macro.var(variable, nil)))

    assert ast == expected
  end

  defp get_function_header(def_function_statement) do
    {:def, _metadata, [function_header | [[do: _function_body]]]} = Code.string_to_quoted!(def_function_statement)

    function_header
  end
end
