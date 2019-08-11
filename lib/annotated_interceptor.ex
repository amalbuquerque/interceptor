defmodule Interceptor.Annotated do

  alias Interceptor.Debug

  @empty_metadata []

  defmacro __using__(opts) do
    own_config = Keyword.get(opts, :config)
    {own_config_module, _bindings} = Code.eval_quoted(own_config)
    Module.put_attribute(__CALLER__.module, :own_config, own_config_module)

    Module.register_attribute(__CALLER__.module, :intercept, accumulate: true)
    Module.register_attribute(__CALLER__.module, :intercepted, accumulate: true)

    quote do
      require Interceptor

      @on_definition {unquote(__MODULE__), :on_definition}
      @before_compile {unquote(__MODULE__), :before_compile}
    end
  end

  def on_definition(env, kind, fun, args, guards, body) do
    Debug.debug_message(
      "\n\n[on_definition] current module=#{env.module}, got Env=(OMITTED), kind=#{inspect(kind)}, fun=#{
        inspect(fun)
      }, args=#{inspect(args)}, guards=#{inspect(guards)}, body=#{inspect(body)}"
    )

    intercept_annotations = Module.get_attribute(env.module, :intercept)

    Debug.debug_message("Intercept annotations #{inspect(intercept_annotations)}")

    attrs = extract_attributes(env.module, body)
    intercepted = {kind, fun, args, guards, body, intercept_annotations, attrs}

    Module.put_attribute(env.module, :intercepted, intercepted)
    Module.delete_attribute(env.module, :intercept)
  end

  defmacro before_compile(env) do
    all_collected = Module.get_attribute(env.module, :intercepted) |> Enum.reverse()
    Module.delete_attribute(env.module, :intercepted)

    to_print =
      all_collected
      |> Enum.reduce("", fn intercepted, acc -> acc <> "#{inspect(intercepted)}\n" end)

    Debug.debug_message("[before_compile] Everything we collected on the @intercepted attribute: #{to_print}")

    intercepted_functions = intercepted_functions(all_collected)

    to_intercept = filter_not_intercepted(all_collected, intercepted_functions)

    to_print =
      to_intercept
      |> Enum.reduce("", fn intercepted, acc -> acc <> "#{inspect(intercepted)}\n" end)

    Debug.debug_message(
      "[before_compile] I should now inject the intercepted functions on the #{env.module}. Here are the intercepted functions to inject: #{
        to_print
      }"
    )

    to_intercept
    |> reject_empty_clauses()
    |> Enum.reduce({nil, []}, fn d, acc ->
      decorate(env, d, acc)
    end)
    |> elem(1)
    |> Enum.reverse()
  end

  # Remove all defs which are not intercepted,
  # these don't need to be overrided.
  defp filter_not_intercepted(all, intercepted_functions) do
    Enum.filter(
      all,
      fn {_kind, fun, args, _guards, _body, _intercepts, _attrs} ->
        Map.has_key?(intercepted_functions, {fun, Enum.count(args)})
      end
    )
  end

  defp intercepted_functions(all) do
    key_fun = fn {_kind, fun, args, _guards, _body, _intercepts, _attrs} ->
      {fun, Enum.count(args)}
    end

    value_fun = fn {_kind, _fun, _args, _guards, _body, intercepts, _attrs} ->
      intercepts
    end

    all
    |> Enum.group_by(key_fun, value_fun)
    |> Enum.filter(fn {_key, intercepts} ->
      List.flatten(intercepts) != []
    end)
    |> Enum.into(%{})
  end

  defp reject_empty_clauses(all) do
    Enum.reject(all, fn {_kind, _fun, _args, _guards, body, _intercepts, _attrs} ->
      body == nil
    end)
  end

  defp implied_arities(args) do
    arity = Enum.count(args)

    default_count =
      args
      |> Enum.filter(fn
        {:\\, _, _} -> true
        _ -> false
      end)
      |> Enum.count()

    :lists.seq(arity, arity - default_count, -1)
  end

  defp decorate(
         env,
         # TODO: We currently ignore the intercepts value, it should be used to override the intercept configuration if passed
         {kind, fun, args, guard, body, _intercepts, attrs},
         {prev_fun, all}
       ) do

    override_clause =
      implied_arities(args)
      |> Enum.map(
        &quote do
          defoverridable [{unquote(fun), unquote(&1)}]
        end
      )

    attrs =
      attrs
      |> Enum.map(fn {attr, value} ->
        {:@, [], [{attr, [], [Macro.escape(value)]}]}
      end)

     function_hdr_and_body = case guard do
       [] -> [
           {fun, @empty_metadata, args},
           body
       ]
       [guard] -> [
           {:when, @empty_metadata, [
             {fun, @empty_metadata, args},
             guard
           ]},
           body
       ]
     end

    def_clause = Interceptor.add_calls({kind, @empty_metadata, function_hdr_and_body}, env.module)

    arity = Enum.count(args)

    if {fun, arity} != prev_fun do
      {{fun, arity}, [def_clause] ++ override_clause ++ attrs ++ all}
    else
      {{fun, arity}, [def_clause] ++ attrs ++ all}
    end
  end

  # Extracts the attributes used in the body of the function,
  # so we can later keep them near the overrided functions.
  defp extract_attributes(module, body) do
    Macro.postwalk(body, %{}, fn
      {:@, _, [{attr, _, nil}]} = node, acc_attrs ->
        acc_attrs = Map.put(acc_attrs, attr, Module.get_attribute(module, attr))
        {node, acc_attrs}

      not_attribute, acc ->
        {not_attribute, acc}
    end)
    # return the accumulated attrs
    |> elem(1)
  end
end
