defmodule FinancialSystem.OperationsTest do
  use ExUnit.Case
  require FinancialSystem.Operations
  alias FinancialSystem.Operations
  alias FinancialSystem.Schemas.Money
  alias FinancialSystem.Data.Accounts

  setup_all do
    [
      balance: Accounts.open_account(1, "10,05") |> elem(1) |> Map.fetch!(:balance),
      acc1: Accounts.open_account(11, "100,00") |> elem(1),
      acc2: Accounts.open_account(12, "55,00") |> elem(1),
      acc3: Accounts.open_account(13, "23,00") |> elem(1)
    ]
  end

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

  describe "defguard is_valid_split/2" do
    # O guard não checa o tipo dos itens da lista, portanto uma lista que não contenha
    # exclusivamente contas válidas mas cumpra os demais requerimentos será considerada válida.
    # A validação das contas é feita em etapa anterior pelo módulo FinancialSystem
    test "Retorna true quando a lista e o montante são válidos para um split", test_data do
      assert Operations.is_valid_split(
               [test_data[:acc1], test_data[:acc2], test_data[:acc3]],
               100_00
             ) == true

      assert Operations.is_valid_split([test_data[:acc1], test_data[:acc2]], 30_00) == true
      assert Operations.is_valid_split([1, 2, 3], 30_00) == true
    end

    test "Retorna false quando os valores são inválidos", test_data do
      assert Operations.is_valid_split([], 100_00) == false
      assert Operations.is_valid_split([test_data[:acc1], test_data[:acc2]], -302) == false
      assert Operations.is_valid_split([test_data[:acc1], test_data[:acc2]], "invalido") == false
    end
  end

  describe "deposit/2" do
    test "Retorna o saldo atualizado após um incremento", test_data do
      assert {:ok, %Money{int: 11, decimal: 30}} = Operations.deposit(test_data[:balance], 125)

      assert {:ok, %Money{int: 60, decimal: 55}} = Operations.deposit(test_data[:balance], 5050)
    end

    test "Falha ao tentar depositar valores não positivos", test_data do
      assert {:error, "O valor a ser creditado precisa ser positivo"} =
               Operations.deposit(test_data[:balance], 0)

      assert {:error, "O valor a ser creditado precisa ser positivo"} =
               Operations.deposit(test_data[:balance], -250)

      assert {:error, "O valor a ser creditado precisa ser positivo"} =
               Operations.deposit(test_data[:balance], "Invalido")
    end
  end

  describe "withdraw/2" do
    test "Retorna o saldo atualizado após um decremento", test_data do
      assert {:ok, %Money{int: 8, decimal: 80}} = Operations.withdraw(test_data[:balance], 1_25)
      assert {:ok, %Money{int: 1, decimal: 55}} = Operations.withdraw(test_data[:balance], 8_50)
      assert {:ok, %Money{int: 0, decimal: 1}} = Operations.withdraw(test_data[:balance], 10_04)
      assert {:ok, %Money{int: 0, decimal: 0}} = Operations.withdraw(test_data[:balance], 10_05)
    end

    test "Falha ao tentar debitar valores não positivos", test_data do
      assert {:error, "O valor a ser debitado precisa ser positivo"} =
               Operations.withdraw(test_data[:balance], 0)

      assert {:error, "O valor a ser debitado precisa ser positivo"} =
               Operations.withdraw(test_data[:balance], -250)

      assert {:error, "O valor a ser debitado precisa ser positivo"} =
               Operations.withdraw(test_data[:balance], "Invalido")
    end

    test "Falha ao tentar debitar valores maiores que o saldo disponível", test_data do
      assert {:error, "Saldo insuficiente"} = Operations.withdraw(test_data[:balance], 5012)
      assert {:error, "Saldo insuficiente"} = Operations.withdraw(test_data[:balance], 2500)
      assert {:error, "Saldo insuficiente"} = Operations.withdraw(test_data[:balance], 1006)
    end
  end

  describe "simple_exchange/2" do
    test "Retorna o valor convertido em uma conversão válida" do
      assert {:ok, 52_50} = Operations.simple_exchange(10_00, 5.25)
      assert {:ok, 13_60} = Operations.simple_exchange(10_00, 1.35987)
      assert {:ok, 52_40} = Operations.simple_exchange(10_00, 5.2433)
      assert {:ok, 79_28} = Operations.simple_exchange(15_10, 5.25)
    end

    test "Falha ao tentar converter valores inválidos" do
      assert {:error, "Dados inválidos para conversão entre moedas"} =
               Operations.simple_exchange("10", 5.25)

      assert {:error, "Dados inválidos para conversão entre moedas"} =
               Operations.simple_exchange("Inválido", 13.10)

      assert {:error, "Dados inválidos para conversão entre moedas"} =
               Operations.simple_exchange(25_32, 8)
    end
  end

  describe "split_amount_by/2" do
    test "Retorna o valor dividido quando os dados são válidos", test_data do
      assert {:ok, 33_33} =
               Operations.split_amount_by(
                 [test_data[:acc1], test_data[:acc2], test_data[:acc3]],
                 100_00
               )

      assert {:ok, 50_00} =
               Operations.split_amount_by(
                 [test_data[:acc1], test_data[:acc2]],
                 100_00
               )
    end

    test "Falha ao tentar fazer um split entre menos de duas contas", test_data do
      assert {:error, "O split necessita de ao menos duas contas de destino"} =
               Operations.split_amount_by([test_data[:acc1]], 100_00)
    end

    test "Falha ao não informar uma lista de contas e um montante válidos", test_data do
      assert {:error, "Dados inválidos para realização do split"} =
               Operations.split_amount_by("teste", 100_00)

      assert {:error, "Dados inválidos para realização do split"} =
               Operations.split_amount_by(test_data[:acc1], 100_00)

      assert {:error, "Dados inválidos para realização do split"} =
               Operations.split_amount_by([test_data[:acc1], test_data[:acc2]], "invalido")
    end

    test "Falha quando o valor informado é 0 ou negativo", test_data do
      assert {:error, "O montante para o split não pode ser 0 ou negativo"} =
               Operations.split_amount_by([test_data[:acc1], test_data[:acc2]], 0)

      assert {:error, "O montante para o split não pode ser 0 ou negativo"} =
               Operations.split_amount_by([test_data[:acc1], test_data[:acc2]], -12_00)
    end
  end
end
