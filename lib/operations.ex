defmodule FinancialSystem.Operations do
  @moduledoc """
  Implementa as operações de incremento e decremento em valores monetários em uma mesma moeda
  e a conversão entre moedas
  """
  alias FinancialSystem.Schemas.{Currency, Money}

  defguard is_valid_amount(amount) when is_integer(amount) and amount > 0

  defguard is_valid_exchange(amount, rate)
           when is_integer(amount) and is_float(rate) and amount > 0 and rate > 0

  defguard is_valid_split(receivers, amount)
           when is_list(receivers) and is_integer(amount) and length(receivers) >= 2 and
                  amount > 0

  @doc """
  Realiza o débito de um dado montade em um valor monetário
  Recebe como parâmetros um valor monétário e o valor a ser debitado
  Retorna uma tupla com :ok e o valor monetário atualizado ou {:error, reason}
  """
  @spec withdraw(balance :: Money.t(), amount :: integer()) ::
          {:ok, Money.t()} | {:error, String.t()}
  def withdraw(balance, amount) when is_valid_amount(amount) do
    balance
    |> to_value()
    |> check_balance(amount)
    |> decrease()
    |> to_money(balance)
    |> maybe_update_balance(balance)
  end

  def withdraw(_balance, _amount), do: {:error, "O valor a ser debitado precisa ser positivo"}

  @doc """
  Credita um montante a um dado valor monetário
  Recebe como parâmetros o valor monetário e o valor a ser creditado
  Retorna uma tupla com :ok e o valor monetário atualizado ou {:error, reason}
  """
  @spec deposit(balance :: Money.t(), amount :: integer()) ::
          {:ok, Money.t()} | {:error, String.t()}
  def deposit(balance, amount) when is_valid_amount(amount) do
    balance
    |> to_value()
    |> increase(amount)
    |> to_money(balance)
    |> maybe_update_balance(balance)
  end

  def deposit(_balance, _amount), do: {:error, "O valor a ser creditado precisa ser positivo"}

  @doc """
  Conversão simples entre moedas supondo que o montande e a taxa de câmbio sejam válidos
  Recebe como entrada o valor a ser convertido e a taxa de conversão
  Retorna uma tupla com :ok e o valor convertido ou {:error, reason}
  """
  @spec simple_exchange(amount :: integer(), rate :: float()) :: {:ok, integer()}
  def simple_exchange(amount, rate) when is_valid_exchange(amount, rate) do
    converted_amount =
      rate
      |> Float.round(2)
      |> Kernel.*(amount)
      |> round()

    {:ok, converted_amount}
  end

  def simple_exchange(_amount, _rate) do
    {:error, "Dados inválidos para conversão entre moedas"}
  end

  def split_amount_by(receivers, _amount) when length(receivers) == 1 do
    {:error, "O split necessita de ao menos duas contas de destino"}
  end

  @doc """
  Divide um valor igualmente entre um número n de contas
  Recebe uma lista de contas e o valor a ser rateado entre as mesmas
  Retorna uma tupla com :ok e o valor dividido ou {:error, reason}
  """
  @spec split_amount_by(receivers :: nonempty_list(Account.t()), amount :: non_neg_integer()) ::
          {:ok, non_neg_integer()} | {:error, String.t()}
  def split_amount_by(receivers, amount) when is_valid_split(receivers, amount) do
    splited_amount = div(amount, length(receivers))

    case splited_amount do
      0 -> {:error, "Valor insuficiente para ser divido entre as contas"}
      _ -> {:ok, splited_amount}
    end
  end

  def split_amount_by(_receivers, amount) when amount <= 0 do
    {:error, "O montante para o split não pode ser 0 ou negativo"}
  end

  def split_amount_by(_receivers, _amount),
    do: {:error, "Dados inválidos para realização do split"}

  @spec to_value(Money.t()) :: integer()
  defp to_value(%Money{int: int, decimal: decimal, currency: currency}) do
    precision = get_precision(currency)
    int * precision + decimal
  end

  @spec get_precision(Currency.t()) :: integer
  defp get_precision(%Currency{precision: precision}) do
    ("1" <> String.duplicate("0", precision))
    |> String.to_integer()
  end

  @spec check_balance(balance :: integer(), amount :: integer()) ::
          {:ok, {integer(), integer()}} | {:error, String.t()}
  defp check_balance(balance, amount) when balance >= amount, do: {:ok, {balance, amount}}

  defp check_balance(_balance, _amount), do: {:error, "Saldo insuficiente"}

  defp to_money({:ok, amount}, _precision) when amount < 10 do
    {:ok, {0, amount}}
  end

  defp to_money({:ok, amount}, %Money{currency: %Currency{precision: precision}}) do
    {int, decimal} =
      amount
      |> to_string()
      |> String.split_at(-precision)

    {:ok, {String.to_integer(int), String.to_integer(decimal)}}
  end

  defp to_money(error, _balance), do: error

  defp increase(balance, amount) do
    {:ok, balance + amount}
  end

  defp decrease({:ok, {balance, amount}}) do
    {:ok, balance - amount}
  end

  defp decrease(error), do: error

  defp maybe_update_balance({:ok, {int, decimal}}, balance) do
    updated_balance = %Money{balance | int: int, decimal: decimal}
    {:ok, updated_balance}
  end

  defp maybe_update_balance(error, _balance), do: error
end
