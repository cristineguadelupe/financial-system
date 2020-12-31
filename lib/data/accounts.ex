defmodule FinancialSystem.Data.Accounts do
  @moduledoc """
  Dados falsos para simulação de transações em contas
  """
  alias FinancialSystem.Data.{Currencies, Moneys}
  alias FinancialSystem.Schemas.{Account, Money}

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
  As contas são abertas por padrão em moeda real
  Retorna {:ok, account} ou {:error, reason}
  """
  @spec open_account(id :: non_neg_integer(), balance :: String.t()) ::
          {:ok, Account.t()} | {:error, String.t()}
  def open_account(id, amount) do
    with {:ok, true} <- validate_amount(amount) do
      balance = string_to_money(amount)
      create(id, balance)
    end
  end

  @doc """
  Cria uma conta a partir de um id e um valor monetário inicial
  Retorna {:ok, account} ou {:error, reason}
  """
  @spec create(id :: non_neg_integer(), balance :: Money.t()) ::
          {:ok, Account.t()} | {:error, String.t()}
  def create(id, %Money{int: int} = balance) when is_integer(id) and int >= 0 and id > 0 do
    account = %Account{id: id, balance: balance}
    {:ok, account}
  end

  def create(id, _balance) when id <= 0 do
    {:error, "O id precisa ser positivo"}
  end

  def create(_id, _balance) do
    {:error, "Não é possível abrir uma conta com dados inválidos"}
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
  def string_to_money(value, currency \\ @real) do
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

  defp validate_amount("-" <> _rest), do: {:error, "O saldo inicial precisa ser zero ou positivo"}

  defp validate_amount(amount) when is_binary(amount) do
    amount
    |> String.match?(~r/^(\d?.+)[,](\d)+$/)
    |> is_valid_amount?()
  end

  defp validate_amount(_amount), do: is_valid_amount?(false)

  defp is_valid_amount?(true), do: {:ok, true}
  defp is_valid_amount?(false), do: {:error, "Informe o saldo inicial no formato 00,00"}
end
