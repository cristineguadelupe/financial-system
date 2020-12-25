defmodule FinancialSystem.AccountsTest do
  use ExUnit.Case
  alias FinancialSystem.Schemas.Account
  alias FinancialSystem.Data.Accounts
  alias FinancialSystem.Data.Currencies
  alias FinancialSystem.Data.Moneys

  @real Currencies.find("BRL") |> elem(1)

  describe "open_account/2" do
    test "Retorna a conta aberta" do
      account_1 = %Account{id: 1, balance: Moneys.create(25230, 00, @real) |> elem(1)}
      assert Accounts.open_account(1, "25.230,00") == {:ok, account_1}

      account_2 = %Account{id: 2, balance: Moneys.create(525, 12, @real) |> elem(1)}
      assert Accounts.open_account(2, "525,12") == {:ok, account_2}

      account_3 = %Account{id: 3, balance: Moneys.create(0, 00, @real) |> elem(1)}
      assert Accounts.open_account(3, "0,00") == {:ok, account_3}
    end
  end

  describe "create/2" do
    test "Retorna a conta criada" do
      account_1 = %Account{id: 1, balance: Moneys.create(100, 00, @real) |> elem(1)}
      balance_1 = Moneys.create(100, 00, @real) |> elem(1)
      assert Accounts.create(1, balance_1) == {:ok, account_1}
    end
  end

  describe "find/1" do
    test "Retorna uma conta" do
      account_1 = %Account{id: 1, balance: Moneys.create(100, 00, @real) |> elem(1)}
      account_2 = %Account{id: 2, balance: Moneys.create(5000, 25, @real) |> elem(1)}
      account_3 = %Account{id: 3, balance: Moneys.create(225, 10, @real) |> elem(1)}

      assert Accounts.find(1) == {:ok, account_1}
      assert Accounts.find(2) == {:ok, account_2}
      assert Accounts.find(3) == {:ok, account_3}
    end

    test "Falha ao procurar por uma conta não cadastrada" do
      assert Accounts.find(4) == {:error, "Conta não encontrada"}
      assert Accounts.find(5) == {:error, "Conta não encontrada"}
      assert Accounts.find(123) == {:error, "Conta não encontrada"}
    end

    test "Falha ao procurar por um conta utilizando um identificador inválido" do
      assert Accounts.find("1") == {:error, "Conta inválida"}
      assert Accounts.find("conta") == {:error, "Conta inválida"}
      assert Accounts.find([1, 2, 3]) == {:error, "Conta inválida"}
    end
  end
end
