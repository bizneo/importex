defmodule Importex.CSV.Cast do
  @moduledoc ~S"""
  Casting and checking fields
  """

  # Cast row based on columnn types and report error if any.
  def row(row, columns) do
    columns
    |> Enum.reduce(%{}, fn({field, type, opts}, accum) ->
      field = case row[field] do
        nil -> opts[:as]
        _ -> field
      end

      case row[field] do
        nil -> accum
        value -> accum |> try_cast(field, type, value, opts)
      end
    end)
  end

  defp try_default("", opts), do: opts[:default]
  defp try_default(value, _), do: value

  defp try_cast(accum, field, type, value, opts) do
    case cast(type, value, opts) do
      {:error, error} ->
        accum
        |> Map.update(:errors, [{field, error}], &(&1 ++ [{field, error}]))
      {:ok, cast_value} ->
        accum |> Map.put(field, cast_value)
    end
  end

  defp cast(:integer, value, opts), do: cast_integer(value, opts)
  defp cast(:email, value, _opts), do: cast_email(value)
  defp cast(:map, value, opts), do: cast_map(value, opts)
  defp cast(:list, value, opts), do: cast_list(value, opts)
  defp cast(:string, value, opts), do: cast_string(value, opts)
  defp cast(_, value, _), do: {:ok, value}

  defp cast_string(value, opts) do
    value = try_default(value, opts)
    {:ok, value}
  end

  defp cast_integer(value, opts) do
    case try_default(value, opts) do
      nil -> error(:integer, value)
      default_value ->
        default_value = case is_integer(default_value) do
          true -> Integer.to_string(default_value)
          false -> default_value
        end

        if Regex.match?(~r/^(\d+)$/, default_value) do
          {:ok, String.to_integer(default_value)}
        else
          error(:integer, value)
        end
    end
  end

  defp cast_email(value) when value in [nil, ""], do: error(:email, value)
  defp cast_email(value) do
    regex = ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/
    if Regex.match?(regex, value) do
      {:ok, value}
    else
      error(:email, value)
    end
  end

  defp cast_map(value, opts) do
    default_value = try_default(value, opts)
    case opts[:values] |> Enum.find(fn({field, _}) -> field == default_value end) do
      {_, v} -> {:ok , v}
      nil -> error(:map, value)
    end
  end

  #defp cast_list(value, _) when value in [nil, ""], do: error(:list, value)
  defp  cast_list(value, opts) do
    default_value = try_default(value, opts)
    opts[:values]
    |> Enum.find_value(&(&1 == default_value))
    |> case do
      true -> {:ok, default_value}
      _ -> error(:list, value)
    end
  end

  defp error(type, value) do
    error = case type do
      :list ->  "'#{value}' is not in the list"
      :map  ->  "'#{value}' is not in the map"
      _ ->      "'#{value}' is not a valid #{type}"
    end
    {:error, error}
  end

end
