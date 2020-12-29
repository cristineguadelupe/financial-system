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
      after_add_1_25 = %Money{
        currency: %FinancialSystem.Schemas.Currency{
          code: "BRL",
          name: "Real",
          number: 986,
          precision: 2
        },
        decimal: 30,
        int: 11
      }

      after_add_50_50 = %Money{
        currency: %FinancialSystem.Schemas.Currency{
          code: "BRL",
          name: "Real",
          number: 986,
          precision: 2
        },
        decimal: 55,
        int: 60
      }

      assert {:ok, after_add_1_25} == Operations.deposit(@balance, 125)
      assert {:ok, after_add_50_50} == Operations.deposit(@balance, 5050)
    end

    test "Falha ao tentar depositar valores não positivos" do
      assert {:error, "O valor a ser creditado precisa ser positivo"} ==
               Operations.deposit(@balance, 0)

      assert {:error, "O valor a ser creditado precisa ser positivo"} ==
               Operations.deposit(@balance, -250)

      assert {:error, "O valor a ser creditado precisa ser positivo"} ==
               Operations.deposit(@balance, "Invalido")
    end
  end

  describe "withdraw/2" do
    test "Retorna o saldo atualizado após um decremento" do
      after_remove_1_25 = %Money{
        currency: %FinancialSystem.Schemas.Currency{
          code: "BRL",
          name: "Real",
          number: 986,
          precision: 2
        },
        decimal: 80,
        int: 8
      }

      after_remove_8_50 = %Money{
        currency: %FinancialSystem.Schemas.Currency{
          code: "BRL",
          name: "Real",
          number: 986,
          precision: 2
        },
        decimal: 55,
        int: 1
      }

      after_remove_10_04 = %Money{
        currency: %FinancialSystem.Schemas.Currency{
          code: "BRL",
          name: "Real",
          number: 986,
          precision: 2
        },
        decimal: 1,
        int: 0
      }

      after_remove_10_05 = %Money{
        currency: %FinancialSystem.Schemas.Currency{
          code: "BRL",
          name: "Real",
          number: 986,
          precision: 2
        },
        decimal: 0,
        int: 0
      }

      assert {:ok, after_remove_1_25} == Operations.withdraw(@balance, 125)
      assert {:ok, after_remove_8_50} == Operations.withdraw(@balance, 850)
      assert {:ok, after_remove_10_04} == Operations.withdraw(@balance, 1004)
      assert {:ok, after_remove_10_05} == Operations.withdraw(@balance, 1005)
    end

    test "Falha ao tentar debitar valores não positivos" do
      assert {:error, "O valor a ser debitado precisa ser positivo"} ==
               Operations.withdraw(@balance, 0)

      assert {:error, "O valor a ser debitado precisa ser positivo"} ==
               Operations.withdraw(@balance, -250)

      assert {:error, "O valor a ser debitado precisa ser positivo"} ==
               Operations.withdraw(@balance, "Invalido")
    end

    test "Falha ao tentar debitar valores maiores que o saldo disponível" do
      assert {:error, "Saldo insuficiente"} == Operations.withdraw(@balance, 5012)
      assert {:error, "Saldo insuficiente"} == Operations.withdraw(@balance, 2500)
      assert {:error, "Saldo insuficiente"} == Operations.withdraw(@balance, 1006)
    end
  end

  describe "simple_exchange/2" do
    test "Retorna o valor convertido em uma conversão válida" do
      assert {:ok, 52_50} == Operations.simple_exchange(10_00, 5.25)
      assert {:ok, 13_60} == Operations.simple_exchange(10_00, 1.35987)
      assert {:ok, 52_40} == Operations.simple_exchange(10_00, 5.2433)
      assert {:ok, 79_28} == Operations.simple_exchange(15_10, 5.25)
    end

    test "Falha ao tentar converter valores inválidos" do
      assert {:error, "Dados inválidos para conversão entre moedas"} ==
               Operations.simple_exchange("10", 5.25)

      assert {:error, "Dados inválidos para conversão entre moedas"} ==
               Operations.simple_exchange("Inválido", 13.10)

      assert {:error, "Dados inválidos para conversão entre moedas"} ==
               Operations.simple_exchange(25_32, 8)
    end
  end
end
