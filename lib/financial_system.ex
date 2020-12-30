defmodule FinancialSystem do
  @moduledoc """
  Implementa as operações de tranferência entre duas ou mais contas
  """

  alias FinancialSystem.Schemas.Account
  alias FinancialSystem.Schemas.Money
  alias FinancialSystem.Schemas.Currency
  alias FinancialSystem.Operations

  @spec transfer_from_to(sender :: Account.t(), receiver :: Account.t(), amount :: String.t()) ::
          {atom(), {Account.t(), Account.t()}} | {atom(), String.t()}
  def transfer_from_to(sender, receiver, amount) when is_binary(amount) do
    transfer_from_to(sender, receiver, to_int(amount))
  end

  @spec transfer_from_to(sender :: Account.t(), receiver :: Account.t(), amount :: integer()) ::
          {atom(), {Account.t(), Account.t()}} | {atom(), String.t()}
  def transfer_from_to(sender, receiver, amount) do
    with {:ok, sender} <- debit_from(sender, amount),
         {:ok, receiver} <- deposit_to(receiver, amount),
         {:ok, _currency} <- validate_currencies(sender, receiver) do
      {:ok, {sender, receiver}}
    end
  end

  def split_from_to(sender, receivers, amount) do
    with {:ok, _valid_receivers} <- validate_receivers(receivers),
         {:ok, splited_amount} <- Operations.split_amount_by(receivers, amount),
         {:ok, sender} <- debit_from(sender, amount),
         {:ok, receivers} <- batch_deposit(receivers, splited_amount),
         {:ok, _message} <- batch_validate_currencies(sender, receivers) do
      {:ok, {sender, receivers}}
    end
  end

  @spec international_transfer(
          sender :: Account.t(),
          receiver :: Account.t(),
          amount :: integer(),
          currency :: Currency.t(),
          rate :: float()
        ) :: {:ok, {Account.t(), Account.t()}} | {:error, String.t()}
  def international_transfer(sender, receiver, amount, currency, rate) do
    with {:ok, converted_amount} <- Operations.simple_exchange(amount, rate),
         {:ok, sender} <- debit_from(sender, converted_amount),
         {:ok, receiver} <- deposit_to(receiver, amount),
         {:ok, _currency} <- validate_currencies(receiver, currency) do
      {:ok, {sender, receiver}}
    end
  end

  defp debit_from({:ok, account}, amount) do
    account
    |> Map.fetch!(:balance)
    |> Operations.withdraw(amount)
    |> maybe_update_account(account)
  end

  defp debit_from({:error, reason}, _amount), do: {:error, reason}
  defp debit_from(_account, _amount), do: {:error, "Operação inválida"}

  defp deposit_to({:ok, account}, amount) do
    account
    |> Map.fetch!(:balance)
    |> Operations.deposit(amount)
    |> maybe_update_account(account)
  end

  defp deposit_to({:error, reason}, _amount), do: {:error, reason}
  defp deposit_to(_account, _amount), do: {:error, "Operação inválida"}

  defp batch_deposit(receivers, amount) do
    receivers
    |> Enum.map(&deposit_to(&1, amount))
    |> Enum.map(&elem(&1, 1))
    |> validate_receivers("Não foi possível realizar todos os depósitos")
  end

  defp maybe_update_account({:ok, balance}, account) do
    {:ok, %Account{account | balance: balance}}
  end

  defp maybe_update_account(error, _account), do: error

  defp to_int(amount) do
    amount
    |> String.match?(~r/^[\d_,\.]+$/)
    |> validate_amount(amount)
  end

  defp validate_amount(true, amount) do
    amount
    |> String.replace(~r/\D/, "")
    |> String.to_integer()
  end

  defp validate_amount(false, _amount), do: :error

  defp batch_validate_currencies(sender, receivers) do
    receivers
    |> Enum.map(&validate_currencies(&1, sender))
    |> Enum.map(&elem(&1, 0))
    |> Enum.all?(&(&1 == :ok))
    |> all_valid_currencies?()
  end

  defp all_valid_currencies?(true), do: {:ok, true}

  defp all_valid_currencies?(false),
    do: {:error, "Não é possível realizar split entre diferentes moedas"}

  defp validate_currencies(%Account{balance: %Money{currency: currency}}, %Account{
         balance: %Money{currency: currency}
       }) do
    {:ok, currency}
  end

  defp validate_currencies(%Account{balance: %Money{currency: currency}}, currency) do
    {:ok, currency}
  end

  defp validate_currencies(_currency, _different_currency) do
    {:error, "Moeda incompatível com a conta de destino"}
  end

  defp validate_receivers(receivers, message \\ "Contas de destino inválidas")

  defp validate_receivers(receivers, message) when is_list(receivers) do
    receivers
    |> Enum.map(&is_account?/1)
    |> Enum.all?()
    |> all_valid_receivers(receivers, message)
  end

  defp validate_receivers(_receivers, message) do
    {:error, message}
  end

  defp is_account?({:ok, %Account{}}), do: true
  defp is_account?(%Account{}), do: true
  defp is_account?(_), do: false

  defp all_valid_receivers(true, receivers, _message), do: {:ok, receivers}
  defp all_valid_receivers(false, _receivers, message), do: {:error, message}
end
