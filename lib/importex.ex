defmodule Importex do
  @moduledoc """
  Documentation for Importex.
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
      import Importex.Base
      @doc """
      Return the import_fields columns of our model

      ## Examples

          iex> Importex.show_columns()
          [{:id, integer}, {:username, :string}, {:email, :string}]

      """
      def show_columns do
        IO.puts "The columns of #{__MODULE__} are (#{inspect @columns})"
      end

      @doc """
      Start the import process from csv file.

      ## Examples

          iex> Importex.import_csv("users.csv")

      """
      def import_csv(file, opts \\ %{}) do
        opts = get_or_set_default(opts)
        parse_csv(file, opts)
      end

      @doc """
      Start the import process from csv file.

      ## Examples

          iex> Importex.import_csv_safe("users.csv")

      """
      def import_csv_safe(file, opts \\ %{}) do
        opts = get_or_set_default(opts)
        parse_csv_safe(file, opts)
      end

      # Get separator and columns from opts params or set default values
      defp get_or_set_default(opts) do
        opts
        |> put_separator
        |> put_columns
      end

      # The separator by default is ";", but it's able change it using syntax
      # ?separator (where separator is the character)
      defp put_separator(opts) do
        separator = cond do
          opts[:separator] != nil -> opts[:separator]
          true -> ?;
        end
        opts |> Map.put_new(:separator, separator)
      end

      # Headers are taking from import_fields macro, one by each column and in
      # the same order, but if we we set opts[:columns] like [{:field1, type1}, ..]
      # this will be taken.
      defp put_columns(opts) do
        case opts[:columns] do
          nil -> opts |> Map.put_new(:columns, Enum.reverse(@columns))
          _ ->
            columns = opts[:columns]
            |> Enum.map(fn(column) ->
              if tuple_size(column) == 2 do
                Tuple.append(column, [])
              else
                column
              end
            end)
            opts |> Map.update(:columns, Enum.reverse(@columns), fn(_) -> columns end)
        end
      end

    end

  end

end
