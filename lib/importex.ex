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
  add to headers
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

          iex> Importex.import("users.csv")

      """
      def import(file, opts \\ %{}) do
        import_csv(file, opts)
      end


      defp import_csv(file, opts) do
        opts = get_or_set_default(opts)
        parse_csv(file, opts)
      end

      defp get_or_set_default(opts) do
        opts
        |> put_separator
        |> put_headers
      end

      defp put_separator(opts) do
        separator = cond do
          opts[:separator] != nil -> opts[:separator]
          true -> ?;
        end
        opts |> Map.put_new(:separator, separator)
      end

      defp put_headers(opts) do
        case opts[:headers] do
          nil -> opts |> Map.put_new(:headers, Enum.reverse(@columns))
          _ ->
            headers = opts[:headers]
            |> Enum.map(fn(column) ->
              if tuple_size(column) == 2 do
                Tuple.append(column, [])
              else
                column
              end
            end)
            opts |> Map.update(:headers, Enum.reverse(@columns), fn(_) -> headers end)
        end
      end

    end

  end

end
