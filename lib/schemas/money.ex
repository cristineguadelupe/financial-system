defmodule FinancialSystem.Schemas.Money do
  @moduledoc """
  Estrutura para representação de valores monetários utilizando apenas inteiros
  """
  alias __MODULE__
  alias FinancialSystem.Schemas.Currency

  @enforce_keys [:int, :decimal, :currency]
  defstruct [:int, :decimal, :currency]

  @typedoc """
  Int: inteiro para representar a parte inteira do valor monetário
  Decimal: inteiro para representar a parte decimal do valor monetário
  Currency: moeda a qual pertence o valor monetário
  """
  @type t :: %Money{
          int: integer(),
          decimal: integer(),
          currency: Currency.t()
        }
end
