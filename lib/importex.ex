defmodule Importex do

  @moduledoc ~S"""
  Importex is a wrapper to import files (by now csv) based on the data fields
  specified in the module that it's been imported.

  ## Types
  These are the options to check and cast fields:

    * `:string` – It's the default type.
    * `:email`  – Check that the email is correct, return error otherwise.
    * `:map` - Must be followed by `:values` , each key represent the value to be read
      and cast by its value. example:
      column :role, :map, values: [{"manager", 0}, {"user", 1}], "manager" will be
      replaced by 0, and "user" by 1. A error will be raised otherwise.
    * `:list` - Similar to `map` but with a list of possible values, example:
      column :gender, :list, values: ["male", "female"]

  ## How to use it:

  This is an example using a `User` module:

  defmodule User do
    use Importex
    import_fields do
      column :email, :email
      column :first_name, :string
      column :second_name, :string, as: :last_name
      column :birth, :string
      column :role, :map, values: [{"manager", 0}, {"user", 1}]
      column :gender, :list, values: ["male", "female"]
      column :company_id, :integer
      column :money, :integer, as: :salary
    end
  end

  """

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute __MODULE__, :columns, accumulate: true
      @before_compile unquote(__MODULE__)
    end
  end

  @doc """
  This macro define a block to register columns you want to import
  """
  defmacro import_fields(block) do
    quote do
      unquote(block)
    end
  end

  @doc """
  This macro should be inside of a import_fields, and generate a new column to
  add to columns
  """
  defmacro column(name, type \\ :string, opts \\ []) do
    quote do
      @columns {unquote(name), unquote(type), unquote(opts)}
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      alias Importex.CSV
      @doc """
      Return the import_fields columns of your model

      ## Examples

          iex> User.columns()
          [{:id, integer}, {:username, :string}, {:email, :string}]

      """
      def columns, do: @columns

      @doc """
      Start a import process from csv file.

      ## Params

      These are the params:

        * `file`  – The file to be imported
        * `opts` – A map of options defined below:

      Options:
        * `:file_include_headers` – The file include headers?:
            false (default) -> Will consider that the file has not headers in the first line,
            so the fields processed will be those in `import_fields` `columns`
            true -> In this case the first line of the line will be taken as the fields to import,
            Note: these fields have to be also part of `import_fields`
        * `:separator` - Which character take as separator.
            ?; (default)
        * `:columns` - A list of tuples ({:field, :type}) to be parsed. Note that this will replace
            `import_fields` columns.
            example: columns: [{:custom_email, :email}, {:custom_money, :string}]

      ## Examples

          iex> User.import_csv("data.csv", %{file_include_headers: true})
          [%{"birth" => "1951-01-01", "company_id" => "1", "contract" => "temporal",
          "email" => "akseli.murto@example.com", "first_name" => "Akseli",
          "gender" => "male", "headquarters" => "Bizneo@Barcelona",
          "last_name" => "Murto", "role" => "user", "salary" => "40000",
          "username" => "ticklishkoala906"}]

      """
      def import_csv(file, opts \\ %{}) do
        CSV.Parser.parse(file, @columns, opts)
      end

      @doc """
      Start a import process from csv file but checking and casting data types.

      ## Params

      These are the params:

        * `file`  – The file to be imported
        * `opts` – A map of options defined below:

      Options:
        * `:file_include_headers` – The file include headers?:
            false (default) -> Will consider that the file has not headers in the first line,
            so the fields processed will be those in `import_fields` `columns`
            true -> In this case the first line of the line will be taken as the fields to import,
            Note: these fields have to be also part of `import_fields`
        * `:separator` - Which character take as separator.
            ?; (default)
        * `:columns` - A list of tuples ({:field, :type}) to be parsed. Note that this will replace
            `import_fields` columns.
            example: columns: [{:custom_email, :email}, {:custom_money, :string}]

      ## Examples

          iex> User.import_csv_safe("data.csv", %{file_include_headers: true})
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
      def import_csv_safe(file, opts \\ %{}) do
        CSV.Parser.parse_safe(file, @columns, opts)
      end

    end

  end

end
