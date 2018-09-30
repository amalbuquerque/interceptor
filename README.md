![Interceptor](https://github.com/amalbuquerque/interceptor/raw/master/assets/images/interceptor_logo_with_title.png)
=========

The Interceptor library allows you to intercept function calls, by configuring
the interception functions and using the `Interceptor.intercept/1` macro.

## Installation

The package can be installed by adding `interceptor` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:interceptor, "~> 0.1.0"}
  ]
end
```

## Getting started

Create a module with a `get/0` function that returns the interception
configuration map.

```elixir
defmodule Interception.Config do
def get, do: %{
  {Intercepted, :abc, 1} => [
    before: {MyInterceptor, :intercept_before, 1},
    after: {MyInterceptor, :intercept_after, 2}
  ]
}
end
```

Point to the previous configuration module in your configuration:

```elixir
# [...]
config :interceptor,
  configuration: Interception.Config
```

Define your interceptor module:

```elixir
defmodule MyInterceptor do
def intercept_before(mfa), do: IO.puts "Intercepted #{inspect(mfa)} before it started."

def intercept_after(mfa, result), do: IO.puts "Intercepted #{inspect(mfa)} after it completed. Its result: #{inspect(result)}"
end
```

In the module that you want to intercept (in our case, `Intercepted`), place
the functions that you want to intercept inside a `Interceptor.intercept/1`
block. If your functions are placed out of this block or if they don't have a
corresponding interceptor configuration, they won't be intercepted. In the next snippet, the `Intercepted.foo/0` function won't be intercepted because it's out of the `Interceptor.intercept/1` do-block.

```elixir
defmodule Intercepted do
require Interceptor, as: I

I.intercept do
  def abc(x), do: "Got #{inspect(x)}"
end

  def foo, do: "Hi there"
end
```

Now when you run your code, whenever the `Intercepted.abc/1` function is
called, it will be intercepted *before* it starts and *after* it completes. You also have a `on_success`, `on_error` and `wrapper` callbacks. Check the full documentation for further examples.

## More info

You can find the library documentation at [https://hexdocs.pm/interceptor](https://hexdocs.pm/interceptor).

