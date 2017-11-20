defmodule Importex.CSV.Utils do
  @moduledoc ~S"""
  Helper module for CSV parser
  """

  # Get separator and columns from opts params or set default values
  def get_or_set_opts(opts, columns) do
    opts
    |> put_separator
    |> put_columns(columns)
  end

  def get_columns(file, opts) do
    if opts[:file_include_headers] do
      headers_file = get_headers_from_file(file, opts)
      # Now we have to find these fields types
      headers_with_type = get_headers_types(headers_file, opts)

      if Enum.any?(headers_with_type) do
        headers_with_type
      else
        opts[:columns]
      end
    else
      opts[:columns]
    end
  end

  # The first file line must not content the header, because we generate This
  # this one base on opts[:columns] or from import_fields macro.
  def read_rows(file, opts) do
    if opts[:file_include_headers] do
      headers =
        file
        |> get_headers_from_file(opts)
        |> replace_headers_by_as(opts)

      file
      |> remove_headers
      |> CSV.decode(separator: opts[:separator] , headers: headers)
    else
      headers =
        opts[:columns]
        |> Enum.map(fn({field, _, _}) -> field end)
        |> replace_headers_by_as(opts)

      file
      |> File.stream!
      |> CSV.decode(separator: opts[:separator] , headers: headers)
    end
  end

  defp get_headers_from_file(file, opts) do
    {:ok, headers_file} =
      file
      |> File.stream!
      |> CSV.decode(separator: opts[:separator])
      |> Enum.fetch(0)

    Enum.map(headers_file, fn(field) -> String.to_atom(field) end)
  end

  defp remove_headers(file) do
    file
    |> File.stream!
    |> Stream.drop(1)
  end

  defp replace_headers_by_as(current_header, %{columns: columns}) do
    Enum.map(current_header, fn(field_name) -> replace_by_as(columns, field_name) end)
  end

  defp replace_by_as(columns, field_name) do
    columns
    |> Enum.find(fn({field, _, _}) -> field == field_name end)
    |> case do
      nil -> field_name
      {_ , _, opts} ->
        if opts[:as] do
          opts[:as]
        else
          field_name
        end
    end
  end

  # Get the types of headers found in file
  defp get_headers_types(headers_file, opts) do
    #opts[:columns]
    headers_file
    |> Enum.reduce([], fn(hf, accum) ->
      accum ++ [Enum.find(opts[:columns], fn({field, _, _}) ->
         "#{field}" == hf
       end)]
    end)
    |> Enum.filter(&(&1 != nil))
  end

  # The separator by default is ";", but it's able change it using syntax
  # ?separator (where separator is the character)
  defp put_separator(opts) do
    separator =
      case opts[:separator] do
        nil -> ?;
        _ -> opts[:separator]
      end
    Map.put_new(opts, :separator, separator)
  end

  # Headers are taking from import_fields macro, one by each column and in
  # the same order, but if we we set opts[:columns] like [{:field1, type1}, ..]
  # this will be taken.
  defp put_columns(opts, columns) do
    case opts[:columns] do
      nil -> Map.put_new(opts, :columns, Enum.reverse(columns))
      _ ->
        columns = Enum.map(opts[:columns], fn(column) -> set_default_opts(column) end)
        Map.update(opts, :columns, Enum.reverse(columns), fn(_) -> columns end)
    end
  end

  defp set_default_opts(column) do
    if tuple_size(column) == 2 do
      Tuple.append(column, [])
    else
      column
    end
  end

end
