defmodule Interceptor.Utils do
  def timestamp(), do: :os.system_time(:microsecond)

  def random_string(length \\ 20) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.encode32()
    |> String.slice(0..length)
    |> String.downcase()
  end

  def random_atom(length \\ 20),
    do:
      length
      |> random_string()
      |> String.to_atom()
end
