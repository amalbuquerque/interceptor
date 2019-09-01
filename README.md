![Interceptor](https://github.com/amalbuquerque/interceptor/raw/master/assets/images/interceptor_logo_with_title.png)

[![Actions Status](https://github.com/amalbuquerque/interceptor/workflows/Tests/badge.svg)](https://github.com/amalbuquerque/interceptor/actions)
=========

The Interceptor library allows you to intercept function calls, by configuring
the interception functions and using the `Interceptor.intercept/1` macro.

## Installation

The package can be installed by adding `interceptor` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:interceptor, "~> 0.4.0"}
  ]
end
```

## Getting started

Create a module using the `Interceptor.Configurator` module:

```elixir
defmodule Interception.Config do
  use Interceptor.Configurator

  intercept "Intercepted.abc/1",
    before: "MyInterceptor.intercept_before/1",
    after: "MyInterceptor.intercept_after/2"
    # there's also `on_success`, `on_error`
    # and `wrapper` callbacks available!
  
  intercept "Intercepted.private_hello/1",
    on_success: "MyInterceptor.intercept_on_success/3"
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
  def intercept_before(mfa),
    do: IO.puts "Intercepted #{inspect(mfa)} before it started."

  def intercept_after(mfa, result),
    do: IO.puts "Intercepted #{inspect(mfa)} after it completed. Its result: #{inspect(result)}"

  def intercept_on_success(mfa, result, _start_timestamp),
    do: IO.puts "Intercepted #{inspect(mfa)} after it completed successfully. Its result: #{inspect(result)}"
end
```

In the module that you want to intercept (in our case, `Intercepted`), place
the functions that you want to intercept inside a `Interceptor.intercept/1`
block. If your functions are placed out of this block or if they don't have
a corresponding interceptor configuration, they won't be intercepted.

In the next snippet, the `Intercepted.foo/0` function won't be intercepted
because it's out of the `Interceptor.intercept/1` do-block. Notice that you can also intercept private functions.

```elixir
defmodule Intercepted do
  require Interceptor, as: I

  I.intercept do
    def abc(x), do: "Got #{inspect(x)}"

    defp private_hello(y), do: "Hello #{inspect(y)}"
  end

  def foo, do: "Hi there"
end
```

Now when you run your code, whenever the `Intercepted.abc/1` function is
called, it will be intercepted *before* it starts and *after* it completes.
Whenever the `Intercepted.private_hello/1` executes successfully, the
corresponding callback will also be called. You also have `on_error` and
`wrapper` callbacks. Check the full documentation for further examples and
other alternative configuration approaches.

## More info

You can find the library documentation at
[https://hexdocs.pm/interceptor](https://hexdocs.pm/interceptor).

## TODO

- Annotated.Interceptor tests;
- Update docs to mention how to understand if we're trying to intercept non-existing functions with the `Interceptor.Configuration.Validator` module;
- Updating docs for the Annotated.Interceptor way.
