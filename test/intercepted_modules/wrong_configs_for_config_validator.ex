defmodule WrongConfigNonExistingModule do
  @config %{
    # the module of the intercepted function *does not exist*, the goal of this
    # is to test the Configuration.Validator.check_if_intercepted_functions_exist/0
    {NonExistingModule, :non_existing_function, 3} => [after: {After.Callback, :right_after, 2}],
    }

  def get_intercept_config(), do: @config
end

defmodule WrongConfigNonExistingFunction do
  @config %{
    # the following intercepted function *do not exist* (the module exists), the goal of this
    # is to test the Configuration.Searcher.check_if_intercepted_functions_exist/0
    {InterceptedByWrapper4, :non_existing_function, 3} => [after: {After.Callback, :right_after, 2}],
    }

  def get_intercept_config(), do: @config
end

defmodule StreamlinedWrongConfigNonExistingModule do
  # TODO
  @config %{
    # the module of the intercepted function *does not exist*, the goal of this
    # is to test the Configuration.Validator.check_if_intercepted_functions_exist/0
    {NonExistingModule, :non_existing_function, 3} => [after: {After.Callback, :right_after, 2}],
    }

  def get_intercept_config(), do: @config
end

defmodule StreamlinedWrongConfigNonExistingFunction do
  # TODO
  @config %{
    # the following intercepted function *do not exist* (the module exists), the goal of this
    # is to test the Configuration.Searcher.check_if_intercepted_functions_exist/0
    {InterceptedByWrapper4, :non_existing_function, 3} => [after: {After.Callback, :right_after, 2}],
    }

  def get_intercept_config(), do: @config
end
