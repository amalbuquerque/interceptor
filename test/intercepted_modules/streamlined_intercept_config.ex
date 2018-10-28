defmodule StreamlinedInterceptConfig do
  use Interceptor.Configurator

  intercept "InterceptedOnBefore1.to_intercept/0",
    before: "Before.Callback.before/1"
  intercept "Bla.Ble.Bli.Module.Name.Big.TooBig.to_intercept/0",
    after: "After.Callback.right_after/2"
end
