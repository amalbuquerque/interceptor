# Changelog for v0.4.0

## Changes

* Fix a bug where we weren't intercepting function definition with guard clauses;
* Interceptor.Configuration.Validator allows one to check if the intercepted functions actually exist;
* Organizing the existing test suite to cater for the "new" annotated tests;
* New "annotated" way of intercepting functions (using `@intercept true`), instead of only supporting the `intercept/1` do-block. Still without the full test-suite, hence not recommended for now.

# Changelog for v0.3.0

## Changes

* Instead of passing the intercepted function arity to the callback functions, we now pass the actual argument values.
This change allows to have the same interceptor function behaving differently with different arguments values.

# Changelog for v0.2.0

## Changes

* `Interceptor.Configurator` provides a DSL to define the intercept configuration, allowing `"Module.function/arity"` MFAs instead of tuple-based ones
* Intercept configuration can now live directly on the intercepted module, instead of being exposed by a module set on the application configuration
* Ability to intercept private functions as well
* Refactor of the configuration code to its own `Interceptor.Configuration` module

## TODO

* Allow multiple callbacks for a given moment, i.e., allow more than one callback to be invoked `after` the intercepted function is called, for example.

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
