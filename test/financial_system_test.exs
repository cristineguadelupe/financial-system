defmodule FinancialSystemTest do
  use ExUnit.Case

  alias FinancialSystem.Schemas.Account
  alias FinancialSystem.Schemas.Currency
  alias FinancialSystem.Schemas.Money

  alias FinancialSystem.Data.Accounts

  @sender Accounts.open_account(1, "250,00")
  @receiver Accounts.open_account(2, "10,00")
  @not_found Accounts.find(5)

  describe "transfer_from_to/3" do
    test "Retorna os saldos atualizados após uma transferência válida" do
      sender_after_send_100_00 = %Account{
        balance: %Money{
          currency: %Currency{
            code: "BRL",
            name: "Real",
            number: 986,
            precision: 2
          },
          decimal: 0,
          int: 150
        },
        id: 1
      }

      receiver_after_receive_100_00 = %Account{
        balance: %Money{
          currency: %Currency{
            code: "BRL",
            name: "Real",
            number: 986,
            precision: 2
          },
          decimal: 0,
          int: 110
        },
        id: 2
      }

      sender_after_send_250_00 = %Account{
        balance: %Money{
          currency: %Currency{
            code: "BRL",
            name: "Real",
            number: 986,
            precision: 2
          },
          decimal: 0,
          int: 0
        },
        id: 1
      }

      receiver_after_receive_250_00 = %Account{
        balance: %Money{
          currency: %Currency{
            code: "BRL",
            name: "Real",
            number: 986,
            precision: 2
          },
          decimal: 0,
          int: 260
        },
        id: 2
      }

      sender_after_send_95_12 = %Account{
        balance: %Money{
          currency: %Currency{
            code: "BRL",
            name: "Real",
            number: 986,
            precision: 2
          },
          decimal: 88,
          int: 154
        },
        id: 1
      }

      receiver_after_receive_95_12 = %Account{
        balance: %Money{
          currency: %Currency{
            code: "BRL",
            name: "Real",
            number: 986,
            precision: 2
          },
          decimal: 12,
          int: 105
        },
        id: 2
      }

      assert FinancialSystem.transfer_from_to(@sender, @receiver, 100_00) ==
               {:ok, {sender_after_send_100_00, receiver_after_receive_100_00}}

      assert FinancialSystem.transfer_from_to(@sender, @receiver, 250_00) ==
               {:ok, {sender_after_send_250_00, receiver_after_receive_250_00}}

      assert FinancialSystem.transfer_from_to(@sender, @receiver, 95_12) ==
               {:ok, {sender_after_send_95_12, receiver_after_receive_95_12}}

      assert FinancialSystem.transfer_from_to(@sender, @receiver, "95,12") ==
               {:ok, {sender_after_send_95_12, receiver_after_receive_95_12}}
    end

    test "Falha ao tentar transferir valores maiores que o saldo disponível" do
      assert FinancialSystem.transfer_from_to(@sender, @receiver, 350_00) ==
               {:error, "Saldo insuficiente"}

      assert FinancialSystem.transfer_from_to(@sender, @receiver, 250_01) ==
               {:error, "Saldo insuficiente"}

      assert FinancialSystem.transfer_from_to(@sender, @receiver, "2.050,01") ==
               {:error, "Saldo insuficiente"}
    end

    test "Falha ao tentar transferir valores negativos ou inválidos" do
      assert FinancialSystem.transfer_from_to(@sender, @receiver, -123_09) ==
               {:error, "O valor a ser debitado precisa ser positivo"}

      assert FinancialSystem.transfer_from_to(@sender, @receiver, "-123_09") ==
               {:error, "O valor a ser debitado precisa ser positivo"}

      assert FinancialSystem.transfer_from_to(@sender, @receiver, 0) ==
               {:error, "O valor a ser debitado precisa ser positivo"}

      assert FinancialSystem.transfer_from_to(@sender, @receiver, "Inválido") ==
               {:error, "O valor a ser debitado precisa ser positivo"}

      assert FinancialSystem.transfer_from_to(@sender, @receiver, "10not12309a90,80number") ==
               {:error, "O valor a ser debitado precisa ser positivo"}
    end

    test "Falha ao tentar transferir entre contas inválidas" do
      assert FinancialSystem.transfer_from_to(@sender, "Inválida", 125_00) ==
               {:error, "Operação inválida"}

      assert FinancialSystem.transfer_from_to("Inválida", @receiver, 125_00) ==
               {:error, "Operação inválida"}
    end

    test "Falha ao tentar transferir para uma conta não encontrada" do
      assert FinancialSystem.transfer_from_to(@sender, @not_found, 125_00) ==
               {:error, "Conta não encontrada"}

      assert FinancialSystem.transfer_from_to(@not_found, @receiver, 125_00) ==
               {:error, "Conta não encontrada"}
    end
  end
end
