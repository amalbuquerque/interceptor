defmodule Interceptor.Utils do
  @mfa_regex ~r/(.*)\.(.*)\/(\d)$/

  def timestamp(), do: :os.system_time(:microsecond)

  def random_string(length \\ 20) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.encode32()
    |> String.slice(0..(length-1))
    |> String.downcase()
  end

  def random_atom(length \\ 20),
    do:
  length
  |> random_string()
  |> String.to_atom()

  def get_mfa_from_string(mfa_string) when is_binary(mfa_string) do
    Regex.run(@mfa_regex, mfa_string)
    |> case do
      nil -> raise("Invalid MFA (#{mfa_string}), it needs to be of the format '<Module>.<Function>/<Arity>'.")
      [_all, string_module, string_function, string_arity] -> mfa_from_string(string_module, string_function, string_arity)
    end
  end

  def get_mfa_from_string({module, function, arity} = mfa) when is_atom(module) and is_atom(function) and is_integer(arity) do
    mfa
  end

  def get_mfa_from_string(not_an_mfa) do
    raise("Invalid MFA (#{inspect(not_an_mfa)}), it needs to be of the format '<Module>.<Function>/<Arity>' or {Module, :function, <arity>}.")
  end

  defp mfa_from_string(string_module, string_function, string_arity) do
    module = String.to_atom("Elixir.#{string_module}")

    {ensure_result, _compiled_module} = Code.ensure_compiled(module)
    compiled? = ensure_result == :module

    function = String.to_atom(string_function)
    arity = String.to_integer(string_arity)

    if !(compiled? && function_exported?(module, function, arity)) do
      IO.puts("Warning! Invalid MFA (#{module}.#{function}/#{arity}), the given function doesn't exist.")
    end

    {module, function, arity}
  end
end
