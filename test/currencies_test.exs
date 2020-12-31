defmodule FinancialSystem.CurrenciesTest do
  use ExUnit.Case
  require FinancialSystem.Data.Currencies
  alias FinancialSystem.Schemas.Currency
  alias FinancialSystem.Data.Currencies

  describe "defguard is_valid_number/1" do
    test "Retorna true se o número é válido" do
      assert Currencies.is_valid_number(1) == true
      assert Currencies.is_valid_number(76) == true
    end

    test "Retorna false se o não é um número valido" do
      assert Currencies.is_valid_number(0) == false
      assert Currencies.is_valid_number(-7) == false
      assert Currencies.is_valid_number("invalido") == false
      assert Currencies.is_valid_number(2500) == false
    end
  end

  describe "find/1" do
    test "Retorna a moeda cadastrada na base" do
      assert {:ok, %Currency{code: "BRL", name: "Real", number: 986, precision: 2}} =
               Currencies.find("BRL")

      assert {:ok, %Currency{code: "USD", name: "Dólar Americano", number: 840, precision: 2}} =
               Currencies.find("USD")

      assert {:ok, %Currency{code: "EUR", name: "Euro", number: 978, precision: 2}} =
               Currencies.find("EUR")
    end

    test "Falha quando a moeda não está cadastrada na base" do
      assert {:error, "Moeda não disponível"} = Currencies.find("CAD")
      assert {:error, "Moeda não disponível"} = Currencies.find("NOK")
      assert {:error, "Moeda não disponível"} = Currencies.find("MXN")
    end

    test "Falha quando o código é inválido" do
      assert {:error, "Código inválido"} = Currencies.find(123)
      assert {:error, "Código inválido"} = Currencies.find("LETRAS")
    end
  end

  describe "create/4" do
    test "Retorna uma moeda criada com sucesso" do
      assert {:ok, %Currency{code: "CAD", name: "Dólar Canadense", number: 124, precision: 2}} =
               Currencies.create("CAD", "Dólar Canadense", 124, 2)

      assert {:ok, %Currency{code: "COP", name: "Peso Colombiano", number: 170, precision: 0}} =
               Currencies.create("COP", "Peso Colombiano", 170, 0)
    end

    test "Falha ao tentar criar uma moeda com dados inválidos" do
      assert {:error, "O código precisa conter exatamente 3 letras"} =
               Currencies.create("Invalido", "Nome da Moeda", 123, 2)

      assert {:error, "O código precisa conter exatamente 3 letras"} =
               Currencies.create(123, "Nome da Moeda", 123, 2)

      assert {:error, "O numero precisa estar entre 1 e 999"} =
               Currencies.create("TST", "Nome da Moeda", "invalido", 2)

      assert {:error, "A precisão precisa ser um numero inteiro não negativo"} =
               Currencies.create("TST", "Nome da Moeda", 123, -9)
    end
  end
end
