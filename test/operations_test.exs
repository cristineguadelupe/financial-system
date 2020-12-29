defmodule FinancialSystem.OperationsTest do
  use ExUnit.Case
  require FinancialSystem.Operations
  alias FinancialSystem.Operations
  alias FinancialSystem.Schemas.Money
  alias FinancialSystem.Data.Accounts

  @balance Accounts.open_account(1, "10,05") |> elem(1) |> Map.fetch!(:balance)

  describe "defguard is_valid_amount/1" do
    test "Retorna true quando o montande é válido" do
      assert Operations.is_valid_amount(12_30) == true
      assert Operations.is_valid_amount(3211_00) == true
    end

    test "Retorna false quando o montante não é válido" do
      assert Operations.is_valid_amount("false") == false
      assert Operations.is_valid_amount(0) == false
      assert Operations.is_valid_amount(-321) == false
    end
  end

  describe "defguard is_valid_exchange/2" do
    test "Retorna true quando ambos valores para uma conversão são válidos" do
      assert Operations.is_valid_exchange(12_20, 5.25) == true
      assert Operations.is_valid_exchange(547_23, 3.458) == true
    end

    test "Retorna falso quando os valores para uma conversão são inválidos" do
      assert Operations.is_valid_exchange(-12_30, 5.25) == false
      assert Operations.is_valid_exchange("teste", 3.458) == false
      assert Operations.is_valid_exchange(0, 3.458) == false
      assert Operations.is_valid_exchange(25_90, 0) == false
      assert Operations.is_valid_exchange(25_90, -2.32) == false
      assert Operations.is_valid_exchange(25_90, "teste") == false
    end
  end

  describe "deposit/2" do
    test "Retorna o saldo atualizado após um incremento" do
      after_add_1_25 =
        {:ok,
         %Money{
           currency: %FinancialSystem.Schemas.Currency{
             code: "BRL",
             name: "Real",
             number: 986,
             precision: 2
           },
           decimal: 30,
           int: 11
         }}

      after_add_50_50 =
        {:ok,
         %Money{
           currency: %FinancialSystem.Schemas.Currency{
             code: "BRL",
             name: "Real",
             number: 986,
             precision: 2
           },
           decimal: 55,
           int: 60
         }}

      assert Operations.deposit(@balance, 125) == after_add_1_25
      assert Operations.deposit(@balance, 5050) == after_add_50_50
    end

    test "Falha ao tentar depositar valores não positivos" do
      assert Operations.deposit(@balance, 0) ==
               {:error, "O valor a ser creditado precisa ser positivo"}

      assert Operations.deposit(@balance, -250) ==
               {:error, "O valor a ser creditado precisa ser positivo"}

      assert Operations.deposit(@balance, "Invalido") ==
               {:error, "O valor a ser creditado precisa ser positivo"}
    end
  end

  describe "withdraw/2" do
    test "Retorna o saldo atualizado após um decremento" do
      after_remove_1_25 =
        {:ok,
         %Money{
           currency: %FinancialSystem.Schemas.Currency{
             code: "BRL",
             name: "Real",
             number: 986,
             precision: 2
           },
           decimal: 80,
           int: 8
         }}

      after_remove_8_50 =
        {:ok,
         %Money{
           currency: %FinancialSystem.Schemas.Currency{
             code: "BRL",
             name: "Real",
             number: 986,
             precision: 2
           },
           decimal: 55,
           int: 1
         }}

      after_remove_10_04 =
        {:ok,
         %Money{
           currency: %FinancialSystem.Schemas.Currency{
             code: "BRL",
             name: "Real",
             number: 986,
             precision: 2
           },
           decimal: 1,
           int: 0
         }}

      after_remove_10_05 =
        {:ok,
         %Money{
           currency: %FinancialSystem.Schemas.Currency{
             code: "BRL",
             name: "Real",
             number: 986,
             precision: 2
           },
           decimal: 0,
           int: 0
         }}

      assert Operations.withdraw(@balance, 125) == after_remove_1_25
      assert Operations.withdraw(@balance, 850) == after_remove_8_50
      assert Operations.withdraw(@balance, 1004) == after_remove_10_04
      assert Operations.withdraw(@balance, 1005) == after_remove_10_05
    end

    test "Falha ao tentar debitar valores não positivos" do
      assert Operations.withdraw(@balance, 0) ==
               {:error, "O valor a ser debitado precisa ser positivo"}

      assert Operations.withdraw(@balance, -250) ==
               {:error, "O valor a ser debitado precisa ser positivo"}

      assert Operations.withdraw(@balance, "Invalido") ==
               {:error, "O valor a ser debitado precisa ser positivo"}
    end

    test "Falha ao tentar debitar valores maiores que o saldo disponível" do
      assert Operations.withdraw(@balance, 5012) == {:error, "Saldo insuficiente"}
      assert Operations.withdraw(@balance, 2500) == {:error, "Saldo insuficiente"}
      assert Operations.withdraw(@balance, 1006) == {:error, "Saldo insuficiente"}
    end
  end

  describe "simple_exchange/2" do
    test "Retorna o valor convertido em uma conversão válida" do
      assert Operations.simple_exchange(10_00, 5.25) == {:ok, 52_50}
      assert Operations.simple_exchange(10_00, 1.35987) == {:ok, 13_60}
      assert Operations.simple_exchange(10_00, 5.2433) == {:ok, 52_40}
      assert Operations.simple_exchange(15_10, 5.25) == {:ok, 79_28}
    end

    test "Falha ao tentar converter valores inválidos" do
      assert Operations.simple_exchange("10", 5.25) ==
               {:error, "Dados inválidos para conversão entre moedas"}

      assert Operations.simple_exchange("Inválido", 13.10) ==
               {:error, "Dados inválidos para conversão entre moedas"}

      assert Operations.simple_exchange(25_32, 8) ==
               {:error, "Dados inválidos para conversão entre moedas"}
    end
  end
end
