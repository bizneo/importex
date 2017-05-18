defmodule Importex.Base do
  import Importex.Types

  def parse_csv(file, %{separator: separator, headers: headers}) do
    file
    |> File.stream!
    |> CSV.decode(separator: separator)
    |> Enum.map(fn row ->
      Enum.reduce(headers, %{pos: 0}, fn({key, type, opts}, accum) ->
        value = Enum.at(row, accum.pos)
        case try_cast(type, value, opts) do
          {:error, error} ->
            accum |> Map.update(:errors, [{key, error}], &(&1 ++ [{key, error}] ))
          {:ok, cast_value} ->
            accum |> Map.put(key, cast_value)
        end
        |> Map.put(:pos, accum.pos + 1)
      end)
      |> Map.delete(:pos)
    end)
  end

end
