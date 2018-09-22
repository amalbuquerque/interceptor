defmodule Outsider do
  def count(message), do: IO.puts("OUTSIDE!!! #{message}")
end

defmodule Intercept do
  defmacro me([do: {_block, _metadata, definitions} = do_block]) do
    # IO.inspect(definitions)

    updated_do_block = definitions
                      |> Enum.map(&add_calls/1)
                      |> update_block_definitions(do_block)

    [do: updated_do_block]
  end

  def add_calls({:def, _metadata, [function_hdr | [[do: function_body]]]} = function) do
    quoted_call = quote do
      Kernel.apply(Outsider, :count, ["Hi there"])
    end

    new_function_body = prepend_to_function_body(function_body, quoted_call)

    new_function = function
    |> put_elem(2, [function_hdr | [[do: new_function_body]]])

    IO.puts("NEW DEF function ####################")
    IO.inspect(new_function)
  end

  def add_calls({:defp, _metadata, [function_hdr | [[do: function_body]]]} = function) do
    function
  end

  def add_calls(something_else) do
    something_else
  end


  defp prepend_to_function_body({:__block__, _metadata, statements} = body, quoted_call) do
    body
    |> put_elem(2, [quoted_call | statements])
  end

  defp prepend_to_function_body(single_statement, quoted_call) do
    {:__block__, [], [quoted_call, single_statement]}
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
    end

    def yyy(), do: IO.puts("alo from yyy")
    def zzz(), do: lalalu("From ZZZ")

    defp lalalu(foo), do: "#{foo} Fa #{foo}"
  end

  def xyz(x) do
    IO.puts("Hey xyz #{x}")
  end
end
