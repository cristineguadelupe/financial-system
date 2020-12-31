defmodule FinancialSystem.MoneysTest do
  use ExUnit.Case

  alias FinancialSystem.Schemas.{Currency, Money}
  alias FinancialSystem.Data.{Currencies, Moneys}

  describe "create/3" do
    setup do
      [
        real: Currencies.find("BRL") |> elem(1),
        euro: Currencies.find("EUR") |> elem(1)
      ]
    end

    test "Retorna o valor monetário", test_data do
      assert {:ok,
              %Money{
                int: 10,
                decimal: 00,
                currency: %Currency{code: "BRL", name: "Real", number: 986, precision: 2}
              }} = Moneys.create(10, 00, test_data[:real])

      assert {:ok,
              %Money{
                int: 25,
                decimal: 50,
                currency: %Currency{code: "BRL", name: "Real", number: 986, precision: 2}
              }} = Moneys.create(25, 50, test_data[:real])

      assert {:ok,
              %Money{
                int: 57,
                decimal: 03,
                currency: %Currency{code: "EUR", name: "Euro", number: 978, precision: 2}
              }} = Moneys.create(57, 03, test_data[:euro])
    end

    test "Falha ao informar valores inválidos", test_data do
      assert {:error, "A parte decimal não pode ser negativa"} =
               Moneys.create(123, -8, test_data[:real])

      assert {:error, "A parte inteira não pode ser negativa"} =
               Moneys.create(-98, 25, test_data[:real])

      assert {:error, "A parte decimal não pode conter mais dígitos que a precisão da moeda"} =
               Moneys.create(123, 128, test_data[:real])
    end
  end
end
