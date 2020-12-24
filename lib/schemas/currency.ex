defmodule FinancialSystem.Schemas.Currency do
  @moduledoc """
  Estrutura para representação de moedas seguindo o padrão internacional ISO 4217
  """
  alias __MODULE__

  @required_keys [:code, :name, :number, :precision]

  @enforce_keys @required_keys
  defstruct [
    :code,
    :name,
    :number,
    :precision
  ]

  @typedoc """
  Code: código ISO 4217 contendo 3 letras ("BRL")
  Name: nome da moeda ("Real)
  Number: número da moeda (986)
  Precision: número de casas decimais (2)
  """
  @type t :: %Currency{
          code: String.t(),
          name: String.t(),
          number: integer(),
          precision: integer()
        }
end
