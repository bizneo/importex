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
        row |> cast_row(opts)
      else
        row
      end
    end)
  end

  # The first file line must not content the header, because we generate This
  # this one base on opts[:headers] or from import_fields macro.
  defp read_rows(file, opts) do
    data_rows   = File.stream!(file)
    headers_row = Enum.reduce(opts[:headers],"", fn({k,_,_}, accum) ->
      if accum == "" do
        "#{k}"
      else
        "#{accum};#{k}"
      end
    end)

    [headers_row]
    |> Stream.concat(data_rows)
    |> CSV.decode(separator: opts[:separator] , headers: true)
  end

  # Cast files and report errors if any.
  defp cast_row(row, opts) do
    Enum.reduce(opts[:headers], %{}, fn({key, type, o}, accum) ->
      value = row["#{key}"]
      case try_cast(type, value, o) do
        {:error, error} ->
          accum |> Map.update(:errors, [{key, error}], &(&1 ++ [{key, error}] ))
        {:ok, cast_value} ->
          accum |> Map.put(key, cast_value)
      end
    end)
  end

end
