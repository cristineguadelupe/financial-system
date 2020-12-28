defmodule FinancialSystem do
  @moduledoc """
  Implementa as operações de tranferência entre duas ou mais contas
  """

  alias FinancialSystem.Schemas.Account
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
         {:ok, receiver} <- deposit_to(receiver, amount) do
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
end
