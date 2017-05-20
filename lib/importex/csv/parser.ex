defmodule Importex.CSV.Parser do
  alias Importex.CSV.Cast
  alias Importex.CSV.Utils

  @moduledoc ~S"""
  CSV parser based on :csv lib.
  """

  @doc """
  Parse csv data and return a list of struct.

  ## Params:
    file: the path to the csv to parse.
    opts: and struct with option params like %{headers: [id: :integer], separator: ?:}
      separator: the csv separator, by default is ';', must be set as "?;".
      headers: a list of header name and type , [{name: :string}, {total: :integer} ... ]

  ## Example:
    iex> Parser.parse("data.csv")
    [%{"birth" => "1951-01-01", "company_id" => "1", "contract" => "temporal",
    "email" => "akseli.murto@example.com", "first_name" => "Akseli",
    "gender" => "male", "headquarters" => "Bizneo@Barcelona",
    "last_name" => "Murto", "role" => "user", "salary" => "40000",
    "username" => "ticklishkoala906"}]
  """
  def parse(file, columns, opts \\ %{}), do: internal_parse_csv(file, columns, opts)

  @doc """
  The same as #parse but checking and casting type params, in case of any error
  an array "errors" will be set on the struct.

  ## Example:
      iex> Parser.parse_safe("data.csv")
      [%{birth: "1951-01-01", company_id: 1, contract: "temporal",
      email: "akseli.murto@example.com", first_name: "Akseli", gender: "male",
      headquarters: "Bizneo@Barcelona", last_name: "Murto", role: "user",
      salary: 40000, username: "ticklishkoala906"}]

      #With wrong data:
      iex> Parser.parse_safe("data_wrong_data.csv")
      %{birth: "1951-01-01", contract: "temporal",
      errors: [email: "'akseli.murtoexample.com' is not a valid email",
      company_id: "'1s' is not a valid integer"], first_name: "Akseli",
      gender: "male", headquarters: "Bizneo@Barcelona", last_name: "Murto",
      role: "user", salary: 40000, username: "ticklishkoala906"}
  """
  def parse_safe(file, columns, opts \\ %{}), do: internal_parse_csv(file, columns, opts, true)

  defp internal_parse_csv(file, columns, opts, cast_rows \\ false) do
    # Set the defaults options, columns and separator
    opts = Utils.get_or_set_opts(opts, columns)
    # If the file_include_headers is set we have to read the first file row, or
    # keep the columns set in import_fields otherwise.
    columns = file |> Utils.get_columns(opts)

    file
    |> Utils.read_rows(opts)
    |> Enum.map(fn(row) ->
      if cast_rows == true do
        row |> Cast.row(columns)
      else
        row
      end
    end)
  end

end
