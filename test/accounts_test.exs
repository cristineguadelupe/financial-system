defmodule FinancialSystem.AccountsTest do
  use ExUnit.Case

  alias FinancialSystem.Schemas.{Account, Currency, Money}
  alias FinancialSystem.Data.{Accounts, Currencies}

  setup_all do
    [
      real: Currencies.find("BRL") |> elem(1),
      usd: Currencies.find("USD") |> elem(1)
    ]
  end

  describe "open_account/2" do
    test "Retorna um conta aberta com sucesso" do
      assert {:ok, %Account{id: 1, balance: %Money{int: 25230, decimal: 0}}} =
               Accounts.open_account(1, "25.230,00")

      assert {:ok, %Account{id: 2, balance: %Money{int: 525, decimal: 12}}} =
               Accounts.open_account(2, "525,12")

      assert {:ok, %Account{id: 3, balance: %Money{int: 0, decimal: 0}}} =
               Accounts.open_account(3, "0,00")
    end

    test "Falha ao tentar abrir uma conta com dados inválidos" do
      assert {:error, "Não é possível abrir uma conta com dados inválidos"} =
               Accounts.open_account("invalido", "35,90")

      assert {:error, "Informe o saldo inicial no formato 00,00"} =
               Accounts.open_account(35, "invalido")

      assert {:error, "Informe o saldo inicial no formato 00,00"} =
               Accounts.open_account(35, "35")

      assert {:error, "O saldo inicial precisa ser zero ou positivo"} =
               Accounts.open_account(35, "-43,87")

      assert {:error, "O id precisa ser positivo"} = Accounts.open_account(-35, "52,31")
    end
  end

  describe "create/2" do
    test "Retorna um conta criada com sucesso", test_data do
      assert {:ok,
              %Account{
                id: 4,
                balance: %Money{
                  int: 100,
                  decimal: 0,
                  currency: %Currency{
                    code: "BRL",
                    name: "Real",
                    number: 986,
                    precision: 2
                  }
                }
              }} = Accounts.create(4, %Money{int: 100, decimal: 0, currency: test_data[:real]})

      assert {:ok,
              %Account{
                id: 5,
                balance: %Money{
                  int: 25,
                  decimal: 16,
                  currency: %Currency{
                    code: "USD",
                    name: "Dólar Americano",
                    number: 840,
                    precision: 2
                  }
                }
              }} = Accounts.create(5, %Money{int: 25, decimal: 16, currency: test_data[:usd]})
    end

    test "Falha ao tentar criar uma conta com dados inválidos", test_data do
      assert {:error, "Não é possível abrir uma conta com dados inválidos"} =
               Accounts.create("invalido", %Money{
                 int: 100,
                 decimal: 0,
                 currency: test_data[:real]
               })

      assert {:error, "Não é possível abrir uma conta com dados inválidos"} =
               Accounts.create(1, "invalido")
    end
  end

  describe "find/1" do
    test "Retorna uma conta cadastrada" do
      assert {:ok, %Account{id: 1, balance: %Money{int: 100, decimal: 0}}} = Accounts.find(1)
      assert {:ok, %Account{id: 2, balance: %Money{int: 5000, decimal: 25}}} = Accounts.find(2)
      assert {:ok, %Account{id: 3, balance: %Money{int: 225, decimal: 10}}} = Accounts.find(3)
    end

    test "Falha ao procurar por uma conta não cadastrada" do
      assert {:error, "Conta não encontrada"} = Accounts.find(4)
      assert {:error, "Conta não encontrada"} = Accounts.find(5)
      assert {:error, "Conta não encontrada"} = Accounts.find(123)
    end

    test "Falha ao procurar por um conta utilizando um identificador inválido" do
      assert {:error, "Conta inválida"} = Accounts.find("1")
      assert {:error, "Conta inválida"} = Accounts.find("conta")
      assert {:error, "Conta inválida"} = Accounts.find([1, 2, 3])
    end
  end
end
