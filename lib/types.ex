defmodule Importex.Types do

  def is_valid(:integer, value), do: check_integer(value)
  def is_valid(:email, value), do: check_email(value)
  def is_valid(_, _), do: true

  defp check_integer(value) when value in [nil, ""], do: false
  defp check_integer(value), do: Regex.match?(~r/^(\d+)$/, value)
  defp check_email(value) when value in [nil, ""], do: false
  defp check_email(value) do
    ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/
    |> Regex.match?(value)
  end

end
