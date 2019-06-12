defmodule Interceptor.Configuration.ValidatorTest do
  use ExUnit.Case, async: true
  alias Interceptor.Configuration.SearcherMock
  import Mox

  @subject Interceptor.Configuration.Validator

  setup :verify_on_exit!

  describe "when every intercepted function exists" do
    setup :searcher_returns_module_with_valid_config

    test "it returns 'true'" do
      assert @subject.check_if_intercepted_functions_exist() == true
    end
  end

  describe "when the module of one of the intercepted functions doesn't exist" do
    setup :searcher_returns_module_with_invalid_config_non_existing_module

    test "it returns 'false'" do
      refute @subject.check_if_intercepted_functions_exist()
    end
  end

  describe "when one of the intercepted functions doesn't exist" do
    setup :searcher_returns_module_with_invalid_config_non_existing_function

    test "it returns 'false'" do
      refute @subject.check_if_intercepted_functions_exist()
    end
  end

  defp searcher_returns_module_with_valid_config(_context) do
    stub(SearcherMock, :search_intercept_config_modules, fn -> [InterceptConfig] end)

    :ok
  end

  defp searcher_returns_module_with_invalid_config_non_existing_module(_context) do
    stub(
      SearcherMock,
      :search_intercept_config_modules,
      fn -> [InterceptConfig, WrongConfigNonExistingModule] end
    )

    :ok
  end

  defp searcher_returns_module_with_invalid_config_non_existing_function(_context) do
    stub(
      SearcherMock,
      :search_intercept_config_modules,
      fn -> [InterceptConfig, WrongConfigNonExistingFunction] end
    )

    :ok
  end
end
