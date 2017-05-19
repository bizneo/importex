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


  def internal_parse_csv(file, opts, cast_rows \\ false) do
    columns = file |> get_columns(opts)

    file
    |> read_rows(opts)
    |> Enum.map(fn row ->
      if cast_rows == true do
        row |> cast_row(columns)
      else
        row
      end
    end)
  end

  # The first file line must not content the header, because we generate This
  # this one base on opts[:columns] or from import_fields macro.
  def read_rows(file, opts) do
    if(opts[:file_include_headers]) do
      headers = file
      |> get_headers_from_file(opts)
      |> replace_headers_by_as(opts)
      |> headers_to_string(opts)

      file
      |> remove_headers
      |> attach_headers(headers)
    else
      headers_row = Enum.reduce(opts[:columns],"", fn({field,_,_}, accum) ->
        if accum == "" do
          "#{field}"
        else
          "#{accum}#{<<opts[:separator]>>}#{field}"
        end
      end)
      data_rows = file |> File.stream!

      [headers_row]
      |> Stream.concat(data_rows)
    end
    |> CSV.decode(separator: opts[:separator] , headers: true)
  end

  # Cast files and report errors if any.
  def cast_row(row, columns) do
    Enum.reduce(columns, %{}, fn({field, type, opts}, accum) ->
      value = row["#{field}"]
      case try_cast(type, value, opts) do
        {:error, error} ->
          accum |> Map.update(:errors, [{field, error}], &(&1 ++ [{field, error}] ))
        {:ok, cast_value} ->
          accum |> Map.put(field, cast_value)
      end
    end)
  end

  def get_columns(file,opts) do
    if(opts[:file_include_headers]) do
      headers_file = file
      |> get_headers_from_file(opts)

      # Now we have to find these fields types
      headers_with_type = headers_file
      |> get_headers_types(opts)

      if Enum.any?(headers_with_type) do
        headers_with_type
      else
        opts[:columns]
      end
    else
      opts[:columns]
    end
  end

  # Read the header from the file (first line)
  def get_headers_from_file(file, opts) do
    {:ok, headers_file } = file
    |> File.stream!
    |> CSV.decode(separator: opts[:separator])
    |> Enum.fetch(0)
    headers_file
  end

  # Get the types of headers found in file
  def get_headers_types(headers_file, opts) do
    opts[:columns]
    headers_file
    |> Enum.reduce([], fn(hf, accum) ->
      accum ++ [opts[:columns] |> Enum.find(fn({h,_,_}) ->
         "#{h}" == hf
       end)]
    end)
    |> Enum.filter(&(&1 != nil))
  end

  def remove_headers(file) do
    file
    |> File.stream!
    |> Stream.drop(1)
  end

  def attach_headers(stream, headers) do
    [headers]
    |> Stream.concat(stream)
  end

  def replace_headers_by_as(current_header, %{columns: columns}) do
    current_header
    |> Enum.map(fn(header_name)->
      columns
      |> Enum.find(fn({field,_,_}) -> "#{field}" == header_name end)
      |> case do
        nil -> header_name
        {_,_,opts} ->
          if opts[:as] do
            opts[:as]
          else
            header_name
          end
      end
    end)
  end

  defp headers_to_string(headers, opts) do
    Enum.reduce(headers,"", fn(col_name, accum) ->
      if accum == "" do
        "#{col_name}"
      else
        "#{accum}#{<<opts[:separator]>>}#{col_name}"
      end
    end)
  end

end
