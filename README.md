![Interceptor](https://github.com/amalbuquerque/interceptor/raw/master/assets/images/interceptor_logo_with_title.png)

[![Actions Status](https://github.com/amalbuquerque/interceptor/workflows/Tests/badge.svg)](https://github.com/amalbuquerque/interceptor/actions) [![Coverage Status](https://coveralls.io/repos/github/amalbuquerque/interceptor/badge.svg?branch=refs/heads/master)](https://coveralls.io/github/amalbuquerque/interceptor?branch=refs/heads/master) [![hex.pm version](https://img.shields.io/hexpm/v/interceptor.svg)](https://hex.pm/packages/interceptor) [![hex.pm downloads](https://img.shields.io/hexpm/dt/interceptor.svg)](https://hex.pm/packages/interceptor)
=========

The Interceptor library allows you to intercept function calls, by configuring
the interception functions and using the `Interceptor.intercept/1` macro or the
`@intercept true` annotation.

## Installation

The package can be installed by adding `interceptor` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:interceptor, "~> 0.5.4"}
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

Define your interceptor module, which contains the callback functions:

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
because it's out of the `Interceptor.intercept/1` do-block. Notice that you
can also intercept private functions.

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

Alternatively, you can use the `Interceptor.Annotated` module and rely on
the `@intercept true` "annotation":

```elixir
defmodule Intercepted do
  use Interceptor.Annotated

  @intercept true
  def abc(x), do: "Got #{inspect(x)}"

  @intercept true
  defp private_hello(y), do: "Hello #{inspect(y)}"

  def foo, do: "Hi there"
end
```

Now when you run your code, whenever the `Intercepted.abc/1` function is
called, it will be intercepted *before* it starts and *after* it completes.
Whenever the `Intercepted.private_hello/1` executes successfully, the
corresponding callback will also be called.

You also have `on_error` and `wrapper` callbacks. Check the full documentation
for further examples and other alternative configuration approaches.

### Wildcarded interception configuration

If you want to intercept all the `Intercepted` module functions without
having to specify an `intercept Intercepted.<function>/<arity>, ...` entry for
each function on the `Interception.Config` module, you can now use wildcards 😎.

The following configuration lets us intercept every `Intercepted` function
(inside the `Interceptor.intercept/1` block or annotated with the
`@intercept true` attribute).

```elixir
defmodule Interception.Config do
  use Interceptor.Configurator

  intercept "Intercepted.*/*",
    before: "MyInterceptor.intercept_before/1",
    after: "MyInterceptor.intercept_after/2"
end
```

## More info

You can find the library documentation at
[https://hexdocs.pm/interceptor](https://hexdocs.pm/interceptor).

You can also find the changelog [here](https://github.com/amalbuquerque/interceptor/blob/master/CHANGELOG.md).

## TODO

- Update docs to mention how to understand if we're trying to intercept non-existing functions with the `Interceptor.Configuration.Validator` module;
