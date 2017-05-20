defmodule Importex.CSV.Cast do
  @moduledoc ~S"""
  Casting and checking fields
  """

  # Cast row based on columnn types and report error if any.
  def row(row, columns) do
    Enum.reduce(columns, %{}, fn({field, type, opts}, accum) ->
      value = row["#{field}"]
      case try_cast(type, value, opts) do
        {:error, error} ->
          accum
          |> Map.update(:errors, [{field, error}], &(&1 ++ [{field, error}]))
        {:ok, cast_value} ->
          accum |> Map.put(field, cast_value)
      end
    end)
  end

  defp try_cast(:integer, value, _opts), do: cast_integer(value)
  defp try_cast(:email, value, _opts), do: cast_email(value)
  defp try_cast(:map, value, opts), do: cast_map(value, opts)
  defp try_cast(:list, value, opts), do: cast_list(value, opts)
  defp try_cast(:string, value, _), do: {:ok, value}
  defp try_cast(_, value, _), do: {:ok, value}

  defp cast_integer(value) when value in [nil, ""], do: error(:integer, value)
  defp cast_integer(value) do
    if Regex.match?(~r/^(\d+)$/, value) do
      {:ok, String.to_integer(value)}
    else
      error(:integer, value)
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

  defp cast_map(value, _) when value in [nil, ""], do: error(:map, value)
  defp cast_map(value, opts) do
    if opts[:values] |> Enum.find_value(fn({field, _}) -> field == value end) do
      {:ok, value}
    else
      error(:map, value)
    end
  end

  defp cast_list(value, _) when value in [nil, ""], do: error(:list, value)
  defp  cast_list(value, opts) do
    opts[:values]
    |> Enum.find_value(&(&1 == value))
    |> case do
      true -> {:ok, value}
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
