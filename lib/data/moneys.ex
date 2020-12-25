defmodule FinancialSystem.Data.Moneys do
  @moduledoc """
  Dados falsos para simulação de operações em dados de valores monetários
  """

  alias FinancialSystem.Schemas.Money
  alias FinancialSystem.Schemas.Currency

  @spec create(int :: integer(), decimal :: integer(), currency :: Currency.t()) ::
          {:ok, Money.t()} | {:error, String.t()}
  def create(int, decimal, currency) do
    money = %Money{int: int, decimal: decimal, currency: currency}
    {:ok, money}
  end

  # TODO: validação dos valores
  # currency precisa ser uma moeda válida e disponível
  # int precisa ser inteiro
  # decimal precisa ser inteiro e corresponder a precisão da moeda
  # o valor precisa ter os 3 campos válidos
  # ou retornar valor inválido e o motivo
end
