defmodule FinancialSystem.Data.Currencies do
  @moduledoc """
  Dados falsos para simulação de moedas cadastradas e diponíveis para transações
  """

  alias FinancialSystem.Schemas.Currency

  @currency_data %{
    "BRL" => %Currency{
      code: "BRL",
      name: "Real",
      number: 986,
      precision: 2
    },
    "USD" => %Currency{
      code: "USD",
      name: "Dólar Americano",
      number: 840,
      precision: 2
    },
    "EUR" => %Currency{
      code: "EUR",
      name: "Euro",
      number: 978,
      precision: 2
    }
  }

  @doc """
  Simula a busca por uma moeda na base de dados
  Retorna {:ok, currency} ou {:error, reason}
  """
  @spec find(code :: String.t()) :: {:ok, Currency.t()} | {:error, String.t()}
  def find(<<code::binary-size(3)>> = code) do
    case Map.get(@currency_data, code) do
      nil -> {:error, "Moeda não disponível"}
      %Currency{} = currency -> {:ok, currency}
    end
  end

  def find(_code), do: {:error, "Código inválido"}
end
