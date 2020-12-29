defmodule FinancialSystemTest do
  use ExUnit.Case

  alias FinancialSystem.Schemas.Account
  alias FinancialSystem.Schemas.Currency
  alias FinancialSystem.Schemas.Money

  alias FinancialSystem.Data.Accounts
  alias FinancialSystem.Data.Currencies
  alias FinancialSystem.Data.Moneys

  @sender Accounts.open_account(1, "250,00")
  @receiver Accounts.open_account(2, "10,00")
  @not_found Accounts.find(5)

  @euro Currencies.find("EUR") |> elem(1)
  @usd Currencies.find("USD") |> elem(1)
  @balance Moneys.create(50, 0, @usd) |> elem(1)
  @usd_account Accounts.create(10, @balance)

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

      assert {:ok, {sender_after_send_100_00, receiver_after_receive_100_00}} ==
               FinancialSystem.transfer_from_to(@sender, @receiver, 100_00)

      assert {:ok, {sender_after_send_250_00, receiver_after_receive_250_00}} ==
               FinancialSystem.transfer_from_to(@sender, @receiver, 250_00)

      assert {:ok, {sender_after_send_95_12, receiver_after_receive_95_12}} ==
               FinancialSystem.transfer_from_to(@sender, @receiver, 95_12)

      assert {:ok, {sender_after_send_95_12, receiver_after_receive_95_12}} ==
               FinancialSystem.transfer_from_to(@sender, @receiver, "95,12")
    end

    test "Falha ao tentar transferir valores maiores que o saldo disponível" do
      assert {:error, "Saldo insuficiente"} ==
               FinancialSystem.transfer_from_to(@sender, @receiver, 350_00)

      assert {:error, "Saldo insuficiente"} ==
               FinancialSystem.transfer_from_to(@sender, @receiver, 250_01)

      assert {:error, "Saldo insuficiente"} ==
               FinancialSystem.transfer_from_to(@sender, @receiver, "2.050,01")
    end

    test "Falha ao tentar transferir valores negativos ou inválidos" do
      assert {:error, "O valor a ser debitado precisa ser positivo"} ==
               FinancialSystem.transfer_from_to(@sender, @receiver, -123_09)

      assert {:error, "O valor a ser debitado precisa ser positivo"} ==
               FinancialSystem.transfer_from_to(@sender, @receiver, "-123_09")

      assert {:error, "O valor a ser debitado precisa ser positivo"} ==
               FinancialSystem.transfer_from_to(@sender, @receiver, 0)

      assert {:error, "O valor a ser debitado precisa ser positivo"} ==
               FinancialSystem.transfer_from_to(@sender, @receiver, "Inválido")

      assert {:error, "O valor a ser debitado precisa ser positivo"} ==
               FinancialSystem.transfer_from_to(@sender, @receiver, "10not12309a90,80number")
    end

    test "Falha ao tentar transferir entre contas inválidas" do
      assert {:error, "Operação inválida"} ==
               FinancialSystem.transfer_from_to(@sender, "Inválida", 125_00)

      assert {:error, "Operação inválida"} ==
               FinancialSystem.transfer_from_to("Inválida", @receiver, 125_00)
    end

    test "Falha ao tentar transferir para uma conta não encontrada" do
      assert {:error, "Conta não encontrada"} ==
               FinancialSystem.transfer_from_to(@sender, @not_found, 125_00)

      assert {:error, "Conta não encontrada"} ==
               FinancialSystem.transfer_from_to(@not_found, @receiver, 125_00)
    end
  end

  describe "international_tranfer_from_to/5" do
    test "Retorna os saldos atualizados após uma transferência internacional válida" do
      sender_after_send_10_20_usd = %Account{
        balance: %Money{
          currency: %Currency{
            code: "BRL",
            name: "Real",
            number: 986,
            precision: 2
          },
          decimal: 45,
          int: 196
        },
        id: 1
      }

      international_receiver_after_receive_10_00_usd = %Account{
        balance: %Money{
          currency: %Currency{
            code: "USD",
            name: "Dólar Americano",
            number: 840,
            precision: 2
          },
          decimal: 20,
          int: 60
        },
        id: 10
      }

      sender_after_send_15_35_usd = %Account{
        balance: %Money{
          currency: %Currency{
            code: "BRL",
            name: "Real",
            number: 986,
            precision: 2
          },
          decimal: 41,
          int: 169
        },
        id: 1
      }

      international_receiver_after_receive_15_35_usd = %Account{
        balance: %Money{
          currency: %Currency{
            code: "USD",
            name: "Dólar Americano",
            number: 840,
            precision: 2
          },
          decimal: 35,
          int: 65
        },
        id: 10
      }

      assert {:ok, {sender_after_send_10_20_usd, international_receiver_after_receive_10_00_usd}} ==
               FinancialSystem.international_transfer(@sender, @usd_account, 10_20, @usd, 5.25)

      assert {:ok, {sender_after_send_15_35_usd, international_receiver_after_receive_15_35_usd}} ==
               FinancialSystem.international_transfer(@sender, @usd_account, 15_35, @usd, 5.25)
    end

    test "Falha ao tentar transferir valores acima do saldo disponível" do
      assert FinancialSystem.international_transfer(@sender, @usd_account, 200_00, @usd, 5.25) ==
               {:error, "Saldo insuficiente"}
    end

    test "Falha ao tentar transferir em moeda diferente da moeda da conta destinatária" do
      assert {:error, "Moeda incompatível com a conta de destino"} ==
               FinancialSystem.international_transfer(@sender, @usd_account, 32_56, @euro, 6.32)
    end

    test "Falha ao informar dados inválidos para conversão" do
      assert {:error, "Dados inválidos para conversão entre moedas"} ==
               FinancialSystem.international_transfer(@sender, @usd_account, 23_05, @usd, 0)

      assert {:error, "Dados inválidos para conversão entre moedas"} ==
               FinancialSystem.international_transfer(@sender, @usd_account, 23_05, @usd, -5.25)

      assert {:error, "Dados inválidos para conversão entre moedas"} ==
               FinancialSystem.international_transfer(@sender, @usd_account, 23_05, @usd, "teste")

      assert {:error, "Dados inválidos para conversão entre moedas"} ==
               FinancialSystem.international_transfer(
                 @sender,
                 @usd_account,
                 "invalido",
                 @usd,
                 5.25
               )
    end
  end
end
