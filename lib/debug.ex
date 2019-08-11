defmodule Interceptor.Debug do
  alias Interceptor.Configuration

  def debug_message(message) do
    case Configuration.debug_mode? do
      true ->
        IO.puts(message)
      _ -> :nop
    end
  end

  def debug_ast(ast) do
    debug_message("############################## Will return the following:")

    ast
    |> Macro.to_string()
    |> debug_message()

    debug_message("############################## Will return the following AST")
    IO.inspect(ast)
  end

end
