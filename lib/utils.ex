defmodule Interceptor.Utils do
  def timestamp(), do: :os.system_time(:microsecond)
end
