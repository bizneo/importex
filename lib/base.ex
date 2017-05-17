defmodule Importex.Base do
  import Importex.Types

  def parse_csv(file, %{separator: separator, headers: headers}) do
    file
    |> File.stream!
    |> CSV.decode(separator: separator)
    |> Enum.map(fn row ->
      Enum.reduce(headers, %{pos: 0}, fn({key, type}, accum) ->
        value = Enum.at(row, accum.pos)
        if(is_valid(type, value)) do
          accum |> Map.put(key, Enum.at(row, accum.pos))
        else
          accum |> attach_error(key, type, value)
        end
        |> Map.put(:pos, accum.pos + 1)
      end)
      |> Map.delete(:pos)
    end)
  end


  defp attach_error(row, key, type, value) do
    init = {key, "#{value} is not #{type}"}
    row
    |> Map.update(:errors, [init], &(&1 ++ [init] ))
  end

end
