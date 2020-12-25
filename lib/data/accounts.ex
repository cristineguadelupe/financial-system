defmodule FinancialSystem.Data.Accounts do
  @moduledoc """
  Dados falsos para simulação de transações em contas
  """
  alias FinancialSystem.Schemas.Account
  alias FinancialSystem.Schemas.Money

  alias FinancialSystem.Data.Currencies
  alias FinancialSystem.Data.Moneys

  @real Currencies.find("BRL") |> elem(1)

  @account_data %{
    1 => %Account{
      id: 1,
      balance: Moneys.create(100, 00, @real) |> elem(1)
    },
    2 => %Account{
      id: 2,
      balance: Moneys.create(5000, 25, @real) |> elem(1)
    },
    3 => %Account{
      id: 3,
      balance: Moneys.create(225, 10, @real) |> elem(1)
    }
  }

  @doc """
  Função para aberturas de contas.
  Recebe o id e o saldo de abertura
  Só é possível abrir contas em moeda real
  """
  @spec open_account(id :: integer(), balance :: String.t()) ::
          {:ok, Account.t()} | {:error, String.t()}
  def open_account(id, amount) do
    balance = string_to_money(amount, @real)
    create(id, balance)
  end

  @spec create(id :: integer(), balance :: Money.t()) :: {:ok, Account.t()} | {:error, String.t()}
  def create(id, balance) do
    account = %Account{id: id, balance: balance}
    {:ok, account}
  end

  @spec find(id :: integer()) :: {:ok, Account.t()} | {:error, String.t()}
  def find(id) when is_integer(id) do
    case Map.get(@account_data, id) do
      nil -> {:error, "Conta não encontrada"}
      %Account{} = account -> {:ok, account}
    end
  end

  def find(_id), do: {:error, "Conta inválida"}

  @doc """
  Pipeline auxiliar para converter string em valor monetário
  Recebe o montante e a moeda
  Retorna o valor monetário do montante
  """
  @spec string_to_money(value :: String.t(), currency :: Currency.t()) :: Money.t()
  def string_to_money(value, currency) do
    value
    |> split_int_and_decimal()
    |> clear_int()
    |> to_integer()
    |> to_money(currency)
  end

  @spec split_int_and_decimal(value :: String.t()) :: {String.t(), String.t()}
  defp split_int_and_decimal(value) do
    value
    |> String.split(",", parts: 2)
    |> List.to_tuple()
  end

  @spec clear_int({int :: String.t(), decimal :: String.t()}) :: {String.t(), String.t()}
  defp clear_int({int, decimal}) do
    {String.replace(int, ".", ""), decimal}
  end

  @spec to_integer({int :: String.t(), decimal :: String.t()}) :: {integer(), integer()}
  defp to_integer({int, decimal}) do
    {String.to_integer(int), String.to_integer(decimal)}
  end

  @spec to_money({int :: integer(), decimal :: integer()}, currency :: Currency.t()) :: Money.t()
  defp to_money({int, decimal}, currency) do
    Moneys.create(int, decimal, currency) |> elem(1)
  end
end
