defmodule FinancialSystem.CurrenciesTest do
  use ExUnit.Case
  alias FinancialSystem.Schemas.Currency
  alias FinancialSystem.Data.Currencies

  describe "find/1" do
    test "Retorna a moeda cadastrada na base" do
      assert Currencies.find("BRL") ==
               {:ok, %Currency{code: "BRL", name: "Real", number: 986, precision: 2}}

      assert Currencies.find("USD") ==
               {:ok, %Currency{code: "USD", name: "Dólar Americano", number: 840, precision: 2}}

      assert Currencies.find("EUR") ==
               {:ok, %Currency{code: "EUR", name: "Euro", number: 978, precision: 2}}
    end

    test "Falha quando a moeda não está cadastrada na base" do
      assert Currencies.find("CAD") == {:error, "Moeda não disponível"}
      assert Currencies.find("NOK") == {:error, "Moeda não disponível"}
      assert Currencies.find("MXN") == {:error, "Moeda não disponível"}
    end

    test "Falha quando o código é inválido" do
      assert Currencies.find(123) == {:error, "Código inválido"}
      assert Currencies.find("LETRAS") == {:error, "Código inválido"}
    end
  end
end
