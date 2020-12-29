defmodule FinancialSystem.CurrenciesTest do
  use ExUnit.Case
  alias FinancialSystem.Schemas.Currency
  alias FinancialSystem.Data.Currencies

  describe "find/1" do
    test "Retorna a moeda cadastrada na base" do
      assert {:ok, %Currency{code: "BRL", name: "Real", number: 986, precision: 2}} ==
               Currencies.find("BRL")

      assert {:ok, %Currency{code: "USD", name: "Dólar Americano", number: 840, precision: 2}} ==
               Currencies.find("USD")

      assert {:ok, %Currency{code: "EUR", name: "Euro", number: 978, precision: 2}} ==
               Currencies.find("EUR")
    end

    test "Falha quando a moeda não está cadastrada na base" do
      assert {:error, "Moeda não disponível"} == Currencies.find("CAD")
      assert {:error, "Moeda não disponível"} == Currencies.find("NOK")
      assert {:error, "Moeda não disponível"} == Currencies.find("MXN")
    end

    test "Falha quando o código é inválido" do
      assert {:error, "Código inválido"} == Currencies.find(123)
      assert {:error, "Código inválido"} == Currencies.find("LETRAS")
    end
  end
end
