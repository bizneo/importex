defmodule Importex.Base do

  def parse_csv(file, headers, separator \\ ?;) do
    file
    |> File.stream!
    |> CSV.decode(separator: separator)
    |> Enum.map(fn row ->
      Enum.reduce(headers, %{pos: 0}, fn({key, _type}, accum) ->
        accum
        |> Map.put(:pos, accum.pos + 1)
        |> Map.put(key, Enum.at(row, accum.pos))
      end)
      |> Map.delete(:pos)
    end)
  end

end
