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
      assert {:ok, account_1} == Accounts.open_account(1, "25.230,00")

      account_2 = %Account{id: 2, balance: Moneys.create(525, 12, @real) |> elem(1)}
      assert {:ok, account_2} == Accounts.open_account(2, "525,12")

      account_3 = %Account{id: 3, balance: Moneys.create(0, 00, @real) |> elem(1)}
      assert {:ok, account_3} == Accounts.open_account(3, "0,00")
    end
  end

  describe "create/2" do
    test "Retorna a conta criada" do
      account_1 = %Account{id: 1, balance: Moneys.create(100, 00, @real) |> elem(1)}
      balance_1 = Moneys.create(100, 00, @real) |> elem(1)
      assert {:ok, account_1} == Accounts.create(1, balance_1)
    end
  end

  describe "find/1" do
    test "Retorna uma conta" do
      account_1 = %Account{id: 1, balance: Moneys.create(100, 00, @real) |> elem(1)}
      account_2 = %Account{id: 2, balance: Moneys.create(5000, 25, @real) |> elem(1)}
      account_3 = %Account{id: 3, balance: Moneys.create(225, 10, @real) |> elem(1)}

      assert {:ok, account_1} == Accounts.find(1)
      assert {:ok, account_2} == Accounts.find(2)
      assert {:ok, account_3} == Accounts.find(3)
    end

    test "Falha ao procurar por uma conta não cadastrada" do
      assert {:error, "Conta não encontrada"} == Accounts.find(4)
      assert {:error, "Conta não encontrada"} == Accounts.find(5)
      assert {:error, "Conta não encontrada"} == Accounts.find(123)
    end

    test "Falha ao procurar por um conta utilizando um identificador inválido" do
      assert {:error, "Conta inválida"} == Accounts.find("1")
      assert {:error, "Conta inválida"} == Accounts.find("conta")
      assert {:error, "Conta inválida"} == Accounts.find([1, 2, 3])
    end
  end
end
