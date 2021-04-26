## Known issues

- None at this time :)

# Changelog for v0.5.4

- Bump `mox`, `ex_doc` and `excoveralls` library versions;
- Allow interception of functions pattern-matching on atom literals, e.g. `def foo(:bar), do: 123`

# Changelog for v0.5.3

* Allow the usage of wildcards when configuring the interception callbacks for a given function, i.e., several intercepted functions can now be configured with a single interception configuration entry by declaring the intercepted function as `{Intercepted, :*, :*}` or `"Intercepted.*/*"`;
* Fix a bug (since the very first version 😅) that forced 0-arity functions to have parens or they wouldn't be intercepted.

# Changelog for v0.5.2

## Changes

* Allow to customize the attribute name when using the `Interceptor.Annotated`, hence we can use an attribute name other than `@intercept`. This will be really useful for a new library I'm thinking about named `cachemere`.

# Changelog for v0.5.1

## Changes

* Fix a bug where, if a function argument wasn't used (e.g. `_arg`) by the original function, interceptor was passing the actual `_arg` value to the callback function. Now, the `:arg_cant_be_intercepted` value it's passed to the callback function instead. This allowed us to fix the compiler warning about "using a `_bla` variable";

* You can intercept your functions using the `Interceptor.Annotated` module and annotating your functions with `@intercept true`, instead of relying on the previous strategy with the `Interceptor.intercept/1` macro.

# Changelog for v0.4.3

## Changes

* Address warning.

# Changelog for v0.4.2

## Changes

* Fix a bug where we were changing the headers of functions for which we didn't have any intercept configuration, leading to unused variables warnings.
Example: original function `def abc(%{x: a}, [b]) do ...` without any intercept configuration, was still being changed to `def abc(%{x: a} = random_var1, [b] = random_var2) do ...`, because this is how we pass the argument values to the callbacks (we resort to those `random_varX` assignments). We now only change the function headers if the given function is in fact configured to be intercepted.

* Fix a bug where intercepted functions pattern-matching on integers or strings were resulting in a compile error. Forgot about literals.

# Changelog for v0.4.1

## Changes

* Fix a bug where we weren't allowing arguments of an intercepted function to destructure existing structures (e.g `def foo(%Media{id: id}, x, y, z)`);

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
