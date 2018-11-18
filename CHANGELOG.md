# Changelog for v0.2.0

## Changes

* `Interceptor.Configurator` provides a DSL to define the intercept configuration, allowing `"Module.function/arity"` MFAs instead of tuple-based ones
* Intercept configuration can now live directly on the intercepted module, instead of being exposed by a module set on the application configuration
* Ability to intercept private functions as well
* Refactor of the configuration code to its own `Interceptor.Configuration` module

# Changelog for v0.1.3

## Changes

* Small documentation fixes
* Bug fix: we had an error when trying to intercept a function without arguments
    - The AST of a `def foo, do: "hi"` function declaration is different from this `def foo(), do: "hi"`

# Changelog for v0.1.2

## Changes

Small documentation fixes.

# Changelog for v0.1.1

## Highlights

First version of the library, with tests and documentation. Implements the
`before`, `after`, `on_success`, `on_error` and `wrapper` strategies of
intercepting any function. As of now, it only intercepts public functions (but
it shouldn't be difficult to intercept private ones as well).
