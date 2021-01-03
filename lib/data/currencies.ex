defmodule FinancialSystem.Data.Currencies do
  @moduledoc """
  Dados falsos para simulação de moedas cadastradas e diponíveis para transações
  """

  alias FinancialSystem.Schemas.Currency

  defguard is_valid_number(number) when is_integer(number) and number > 0 and number < 1000

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

  @doc """
  Cria uma moeda seguindo a especificação do padrão internacional ISO 4217
  Recebe como entrada o código de 3 letras, o nome da moeda, o número da moeda e a precisão da mesma
  Retorna uma tupla com :ok e a moeda recém criada ou {:error, reason}
  """
  @spec create(
          code :: String.t(),
          name :: String.t(),
          number :: non_neg_integer(),
          precision :: non_neg_integer()
        ) :: {:ok, Currency.t()} | {:error, String.t()}
  def create(code, name, number, precision) do
    with {:ok, code} <- validate_code(code),
         {:ok, name} <- validate_name(name),
         {:ok, number} <- validate_number(number),
         {:ok, precision} <- validate_precision(precision) do
      currency = %Currency{
        code: code,
        name: name,
        number: number,
        precision: precision
      }

      {:ok, currency}
    end
  end

  defp validate_code(code) when is_binary(code) do
    code
    |> String.match?(~r/^[a-zA-Z]{3}$/)
    |> is_valid_code?(code)
  end

  defp validate_code(code), do: is_valid_code?(false, code)

  defp is_valid_code?(true, code), do: {:ok, String.upcase(code)}
  defp is_valid_code?(false, _code), do: {:error, "O código precisa conter exatamente 3 letras"}

  defp validate_name(name) when is_binary(name), do: {:ok, name}
  defp validate_name(_), do: {:error, "Informe um nome válido"}

  defp validate_number(number) when is_valid_number(number), do: {:ok, number}
  defp validate_number(_number), do: {:error, "O numero precisa estar entre 1 e 999"}

  defp validate_precision(precision) when is_integer(precision) and precision >= 0 do
    {:ok, precision}
  end

  defp validate_precision(_precision),
    do: {:error, "A precisão precisa ser um numero inteiro não negativo"}
end
