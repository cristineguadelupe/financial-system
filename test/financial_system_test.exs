defmodule FinancialSystemTest do
  use ExUnit.Case

  alias FinancialSystem.Schemas.{Account, Currency, Money}
  alias FinancialSystem.Data.{Accounts, Currencies}

  setup_all do
    [
      sender: Accounts.open_account(1, "250,00"),
      receiver: Accounts.open_account(2, "10,00"),
      not_found: Accounts.find(5),
      euro: Currencies.find("EUR") |> elem(1),
      usd: Currencies.find("USD") |> elem(1),
      usd_account:
        Accounts.create(10, %Money{
          int: 50,
          decimal: 0,
          currency: %Currency{code: "USD", name: "Dólar Americano", number: 840, precision: 2}
        })
    ]
  end

  describe "transfer_from_to/3" do
    test "Retorna os saldos atualizados após uma transferência válida", test_data do
      assert {:ok,
              {%Account{balance: %Money{int: 150, decimal: 0}},
               %Account{balance: %Money{int: 110, decimal: 0}}}} =
               FinancialSystem.transfer_from_to(test_data[:sender], test_data[:receiver], 100_00)

      assert {:ok,
              {%Account{balance: %Money{int: 0, decimal: 0}},
               %Account{balance: %Money{int: 260, decimal: 0}}}} =
               FinancialSystem.transfer_from_to(test_data[:sender], test_data[:receiver], 250_00)

      assert {:ok,
              {%Account{balance: %Money{int: 154, decimal: 88}},
               %Account{balance: %Money{int: 105, decimal: 12}}}} =
               FinancialSystem.transfer_from_to(test_data[:sender], test_data[:receiver], 95_12)

      assert {:ok,
              {%Account{balance: %Money{int: 154, decimal: 88}},
               %Account{balance: %Money{int: 105, decimal: 12}}}} =
               FinancialSystem.transfer_from_to(test_data[:sender], test_data[:receiver], "95,12")
    end

    test "Falha ao tentar transferir valores maiores que o saldo disponível", test_data do
      assert {:error, "Saldo insuficiente"} =
               FinancialSystem.transfer_from_to(test_data[:sender], test_data[:receiver], 350_00)

      assert {:error, "Saldo insuficiente"} =
               FinancialSystem.transfer_from_to(test_data[:sender], test_data[:receiver], 250_01)

      assert {:error, "Saldo insuficiente"} =
               FinancialSystem.transfer_from_to(
                 test_data[:sender],
                 test_data[:receiver],
                 "2.050,01"
               )
    end

    test "Falha ao tentar transferir valores negativos ou inválidos", test_data do
      assert {:error, "O valor a ser debitado precisa ser positivo"} =
               FinancialSystem.transfer_from_to(test_data[:sender], test_data[:receiver], -123_09)

      assert {:error, "O valor a ser debitado precisa ser positivo"} =
               FinancialSystem.transfer_from_to(
                 test_data[:sender],
                 test_data[:receiver],
                 "-123,09"
               )

      assert {:error, "O valor a ser debitado precisa ser positivo"} =
               FinancialSystem.transfer_from_to(test_data[:sender], test_data[:receiver], 0)

      assert {:error, "O valor a ser debitado precisa ser positivo"} =
               FinancialSystem.transfer_from_to(
                 test_data[:sender],
                 test_data[:receiver],
                 "Inválido"
               )

      assert {:error, "O valor a ser debitado precisa ser positivo"} =
               FinancialSystem.transfer_from_to(
                 test_data[:sender],
                 test_data[:receiver],
                 "10not12309a90,80number"
               )
    end

    test "Falha ao tentar transferir entre contas inválidas", test_data do
      assert {:error, "Operação inválida"} =
               FinancialSystem.transfer_from_to(test_data[:sender], "Inválida", 125_00)

      assert {:error, "Operação inválida"} =
               FinancialSystem.transfer_from_to("Inválida", test_data[:receiver], 125_00)
    end

    test "Falha ao tentar transferir para uma conta não encontrada", test_data do
      assert {:error, "Conta não encontrada"} =
               FinancialSystem.transfer_from_to(test_data[:sender], test_data[:not_found], 125_00)

      assert {:error, "Conta não encontrada"} =
               FinancialSystem.transfer_from_to(
                 test_data[:not_found],
                 test_data[:receiver],
                 125_00
               )
    end

    test "Falha ao tentar tranferir para contas de moeda diferente", test_data do
      assert {:error, "Moeda incompatível com a conta de destino"} =
               FinancialSystem.transfer_from_to(
                 test_data[:sender],
                 test_data[:usd_account],
                 200_00
               )
    end
  end

  describe "international_tranfer_from_to/5" do
    test "Retorna os saldos atualizados após uma transferência internacional válida", test_data do
      assert {:ok,
              {%Account{balance: %Money{int: 196, decimal: 45}},
               %Account{balance: %Money{int: 60, decimal: 20}}}} =
               FinancialSystem.international_transfer(
                 test_data[:sender],
                 test_data[:usd_account],
                 10_20,
                 test_data[:usd],
                 5.25
               )

      assert {:ok,
              {%Account{balance: %Money{int: 169, decimal: 41}},
               %Account{balance: %Money{int: 65, decimal: 35}}}} =
               FinancialSystem.international_transfer(
                 test_data[:sender],
                 test_data[:usd_account],
                 15_35,
                 test_data[:usd],
                 5.25
               )
    end

    test "Falha ao tentar transferir valores acima do saldo disponível", test_data do
      assert {:error, "Saldo insuficiente"} =
               FinancialSystem.international_transfer(
                 test_data[:sender],
                 test_data[:usd_account],
                 200_00,
                 test_data[:usd],
                 5.25
               )
    end

    test "Falha ao tentar transferir em moeda diferente da moeda da conta destinatária",
         test_data do
      assert {:error, "Moeda incompatível com a conta de destino"} =
               FinancialSystem.international_transfer(
                 test_data[:sender],
                 test_data[:usd_account],
                 32_56,
                 test_data[:euro],
                 6.32
               )
    end

    test "Falha ao informar dados inválidos para conversão", test_data do
      assert {:error, "Dados inválidos para conversão entre moedas"} =
               FinancialSystem.international_transfer(
                 test_data[:sender],
                 test_data[:usd_account],
                 23_05,
                 test_data[:usd],
                 0
               )

      assert {:error, "Dados inválidos para conversão entre moedas"} =
               FinancialSystem.international_transfer(
                 test_data[:sender],
                 test_data[:usd_account],
                 23_05,
                 test_data[:usd],
                 -5.25
               )

      assert {:error, "Dados inválidos para conversão entre moedas"} =
               FinancialSystem.international_transfer(
                 test_data[:sender],
                 test_data[:usd_account],
                 23_05,
                 test_data[:usd],
                 "teste"
               )

      assert {:error, "Dados inválidos para conversão entre moedas"} =
               FinancialSystem.international_transfer(
                 test_data[:sender],
                 test_data[:usd_account],
                 "invalido",
                 test_data[:usd],
                 5.25
               )
    end
  end

  describe "split_from_to/3" do
    setup do
      [
        acc1: Accounts.open_account(11, "300,00"),
        acc2: Accounts.open_account(22, "10,00"),
        acc3: Accounts.open_account(33, "0,00"),
        acc4: Accounts.open_account(44, "25,32")
      ]
    end

    test "Retorna os saldos atualizados quando um split é realizado com sucesso", test_data do
      assert {:ok,
              {%Account{balance: %Money{int: 200, decimal: 0}},
               [
                 %Account{balance: %Money{int: 43, decimal: 33}},
                 %Account{balance: %Money{int: 33, decimal: 33}},
                 %Account{balance: %Money{int: 58, decimal: 65}}
               ]}} =
               FinancialSystem.split_from_to(
                 test_data[:acc1],
                 [test_data[:acc2], test_data[:acc3], test_data[:acc4]],
                 100_00
               )

      assert {:ok,
              {%Account{balance: %Money{int: 0, decimal: 0}},
               [
                 %Account{balance: %Money{int: 160, decimal: 00}},
                 %Account{balance: %Money{int: 150, decimal: 00}}
               ]}} =
               FinancialSystem.split_from_to(
                 test_data[:acc1],
                 [test_data[:acc2], test_data[:acc3]],
                 300_00
               )
    end

    test "Falha ao informar montantes acima do saldo disponível", test_data do
      assert {:error, "Saldo insuficiente"} =
               FinancialSystem.split_from_to(
                 test_data[:acc1],
                 [test_data[:acc2], test_data[:acc3]],
                 450_00
               )
    end

    test "Falha ao tentar split para menos de duas contas", test_data do
      assert {:error, "O split necessita de ao menos duas contas de destino"} =
               FinancialSystem.split_from_to(test_data[:acc1], [test_data[:acc2]], 120_90)
    end

    test "Falha ao informar montantes inferiores ao mínimo necessário", test_data do
      assert {:error, "Valor insuficiente para ser divido entre as contas"} =
               FinancialSystem.split_from_to(
                 test_data[:acc1],
                 [test_data[:acc2], test_data[:acc3], test_data[:acc4]],
                 2
               )

      assert {:error, "Valor insuficiente para ser divido entre as contas"} =
               FinancialSystem.split_from_to(
                 test_data[:acc1],
                 [test_data[:acc2], test_data[:acc3]],
                 1
               )
    end

    test "Falha o informar contas de destino inválidas", test_data do
      assert {:error, "Contas de destino inválidas"} =
               FinancialSystem.split_from_to(
                 test_data[:acc1],
                 "inválido",
                 10_00
               )

      assert {:error, "Contas de destino inválidas"} =
               FinancialSystem.split_from_to(
                 test_data[:acc1],
                 [1, 2, 3],
                 10_00
               )

      assert {:error, "Contas de destino inválidas"} =
               FinancialSystem.split_from_to(
                 test_data[:acc1],
                 [test_data[:acc2], 2, 3],
                 10_00
               )

      assert {:error, "Contas de destino inválidas"} =
               FinancialSystem.split_from_to(
                 test_data[:acc1],
                 [test_data[:acc2], "invalida", test_data[:acc3]],
                 10_00
               )
    end

    test "Falha ao tentar um split com outros dados inválidos", test_data do
      assert {:error, "Operação inválida"} =
               FinancialSystem.split_from_to(
                 "invalido",
                 [test_data[:acc2], test_data[:acc3]],
                 10_00
               )
    end

    test "Falha ao tentar realizar split entre contas com diferentes moedas", test_data do
      assert {:error, "Não é possível realizar split entre diferentes moedas"} =
               FinancialSystem.split_from_to(
                 test_data[:acc1],
                 [test_data[:acc2], test_data[:acc3], test_data[:usd_account]],
                 10_00
               )
    end
  end
end
