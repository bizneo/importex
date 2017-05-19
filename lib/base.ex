defmodule Importex.Base do
  import Importex.Types

  @doc """
  Parse csv data and return a list of struct.

  ## Params:
    file: the path to the csv to parse.
    opts: and struct with option params like %{headers: [id: :integer], separator: ?:}
      separator: the csv separator, by default is ';', must be set as "?;".
      headers: a list of header name and type , [{name: :string}, {total: :integer} ... ]

  ## Example:
    iex> User.import_csv("data.csv")
    [%{"birth" => "1951-01-01", "company_id" => "1", "contract" => "temporal",
    "email" => "akseli.murto@example.com", "first_name" => "Akseli",
    "gender" => "male", "headquarters" => "Bizneo@Barcelona",
    "last_name" => "Murto", "role" => "user", "salary" => "40000",
    "username" => "ticklishkoala906"}]
  """
  def parse_csv(file, opts \\ %{}), do: internal_parse_csv(file, opts)

  @doc """
  The same as #parse_csv but checking and casting type params, in case of any error
  an array "errors" will be set on the struct.

  ## Example:
      iex> User.import_csv_safe("data.csv")
      [%{birth: "1951-01-01", company_id: 1, contract: "temporal",
      email: "akseli.murto@example.com", first_name: "Akseli", gender: "male",
      headquarters: "Bizneo@Barcelona", last_name: "Murto", role: "user",
      salary: 40000, username: "ticklishkoala906"}]

      #With wrong data:
      iex> User.import_csv_safe("data_wrong_data.csv")
      %{birth: "1951-01-01", contract: "temporal",
      errors: [email: "'akseli.murtoexample.com' is not a valid email",
      company_id: "'1s' is not a valid integer"], first_name: "Akseli",
      gender: "male", headquarters: "Bizneo@Barcelona", last_name: "Murto",
      role: "user", salary: 40000, username: "ticklishkoala906"}
  """
  def parse_csv_safe(file, opts \\ %{}), do: internal_parse_csv(file, opts, true)


  defp internal_parse_csv(file, opts, cast_rows \\ false) do
    file
    |> read_rows(opts)
    |> Enum.map(fn row ->
      if cast_rows == true do
        headers = file
        |> get_headers(opts)
        row |> cast_row(headers)
      else
        row
      end
    end)
  end

  # The first file line must not content the header, because we generate This
  # this one base on opts[:headers] or from import_fields macro.
  defp read_rows(file, opts) do
    data_rows   = File.stream!(file)
    if(opts[:include_headers]) do
      data_rows
    else
      headers_row = Enum.reduce(opts[:headers],"", fn({k,_,_}, accum) ->
        if accum == "" do
          "#{k}"
        else
          "#{accum}#{<<opts[:separator]>>}#{k}"
        end
      end)
      [headers_row]
      |> Stream.concat(data_rows)
    end
    |> CSV.decode(separator: opts[:separator] , headers: true)
  end

  # Cast files and report errors if any.
  defp cast_row(row, headers) do
    Enum.reduce(headers, %{}, fn({key, type, o}, accum) ->
      value = row["#{key}"]
      case try_cast(type, value, o) do
        {:error, error} ->
          accum |> Map.update(:errors, [{key, error}], &(&1 ++ [{key, error}] ))
        {:ok, cast_value} ->
          accum |> Map.put(key, cast_value)
      end
    end)
  end

  defp get_headers(file,opts) do
    if(opts[:include_headers]) do
      headers_file = file
      |> get_headers_from_file(opts)
      # Now we have to find these fields types
      headers_with_type = headers_file
      |> get_headers_types(opts)

      if Enum.any?(headers_with_type) do
        headers_with_type
      else
        opts[:headers]
      end
    else
      opts[:headers]
    end
  end

  # Read the header from the file (first line)
  defp get_headers_from_file(file, opts) do
    {:ok, headers_file } = file
    |> File.stream!
    |> CSV.decode(separator: opts[:separator])
    |> Enum.fetch(0)
    headers_file
  end

  # Get the types of headers found in file
  defp get_headers_types(headers_file, opts) do
    headers_file
    |> Enum.reduce([], fn(hf, accum) ->
      accum ++ [opts[:headers] |> Enum.find(fn({h,_,_}) -> "#{h}" == hf end)]
    end)
    |> Enum.filter(&(&1 != nil))
  end

end
