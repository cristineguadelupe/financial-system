defmodule FinancialSystem.Data.Moneys do
  @moduledoc """
  Dados falsos para simulação de operações em dados de valores monetários
  """

  alias FinancialSystem.Schemas.Money
  alias FinancialSystem.Schemas.Currency

  @spec create(int :: integer(), decimal :: integer(), currency :: Currency.t()) ::
          {:ok, Money.t()} | {:error, String.t()}
  def create(int, decimal, currency) do
    with {:ok, int} <- validate_int(int),
         {:ok, decimal} <- validate_decimal(decimal, currency) do
      money = %Money{int: int, decimal: decimal, currency: currency}
      {:ok, money}
    end
  end

  defp validate_int(int) when is_integer(int) and int >= 0, do: {:ok, int}
  defp validate_int(_int), do: {:error, "A parte inteira não pode ser negativa"}

  defp validate_decimal(decimal, _currency) when is_integer(decimal) and decimal < 0 do
    {:error, "A parte decimal não pode ser negativa"}
  end

  defp validate_decimal(0 = decimal, _currency), do: {:ok, decimal}

  defp validate_decimal(decimal, %Currency{precision: precision}) when is_integer(decimal) do
    decimal_precision =
      decimal
      |> Integer.digits()
      |> length()

    case decimal_precision do
      decimal_precision when decimal_precision <= precision -> {:ok, decimal}
      _ -> {:error, "A parte decimal não pode conter mais dígitos que a precisão da moeda"}
    end
  end
end
