defmodule FinancialSystem.Schemas.Account do
  @moduledoc """
  Estrutura para representar uma conta
  """
  alias __MODULE__
  alias FinancialSystem.Schemas.Money

  @enforce_keys [:id, :balance]
  defstruct [:id, :balance]

  @typedoc """
  Id: código identificador da conta
  Balance: Saldo disponível
  """
  @type t :: %Account{
          id: integer(),
          balance: Money.t()
        }
end
