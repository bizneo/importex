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
  defmacro column(name, type) do
    quote do
      @columns {unquote(name), unquote(type)}
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
      def import(file, headers \\ {}) do
        case headers do
          {} -> import_csv(file, @columns, true)
          _  -> import_csv(file, headers)
        end
      end


      defp import_csv(file, headers, reverse \\ false) do
        headers = if reverse do
          Enum.reverse(headers)
        else
          headers
        end
        parse_csv(file, headers)
      end

    end
  end

end
