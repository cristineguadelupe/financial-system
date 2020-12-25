defmodule FinancialSystem.MoneysTest do
  use ExUnit.Case
  alias FinancialSystem.Schemas.Money
  alias FinancialSystem.Data.Moneys
  alias FinancialSystem.Data.Currencies

  describe "create/3" do
    test "Retorna o valor monetário" do
      real = Currencies.find("BRL") |> elem(1)
      euro = Currencies.find("EUR") |> elem(1)
      assert Moneys.create(10, 00, real) == {:ok, %Money{int: 10, decimal: 00, currency: real}}
      assert Moneys.create(25, 50, real) == {:ok, %Money{int: 25, decimal: 50, currency: real}}
      assert Moneys.create(57, 03, euro) == {:ok, %Money{int: 57, decimal: 03, currency: euro}}
    end
  end
end
