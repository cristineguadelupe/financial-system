# Sistema Financeiro

[![Coverage Status](https://coveralls.io/repos/github/cristineguadelupe/financial-system/badge.svg?t=IBYgYY)](https://coveralls.io/github/cristineguadelupe/financial-system)

## Sobre o projeto

Aplicação backend de um sistema financeiro que possibilita a transferência entre contas de uma mesma moeda, rateio de valores entre duas ou mais contas de uma mesma moeda e conversão entre moedas para transferências internacionais.
O sistema representa valores monetários sem o uso de ponto flutuante e moedas seguindo o padrão internacional [ISO 4217](https://pt.wikipedia.org/wiki/ISO_4217)


### Teconologias

* [Elixir](https://elixir-lang.org)
* [Credo](https://hex.pm/packages/credo)
* [Coveralls](https://coveralls.io)
* [GitHub Actions](https://github.com/features/actions)


## Instruções

Para obter uma cópia local funcionando, siga os passos seguintes:

### Pré Requisitos

É pré requisito para a execução do projeto a linguagem Elixir instalada e funcionando

### Instalação

1. Clone este repositório
   ```sh
   git clone https://github.com/cristineguadelupe/financial-system
   ```
2. Instale as dependências
   ```sh
   mix deps.get
   ```
3. Rode os testes
    ```sh
    mix test
    ```
4. Inicie via IEX
    ```sh
    iex -S mix
    ```


## Principais recursos
O sistema possibilida a transferência de valores monetários entre contas de uma uma mesma moeda, o rateio de valores entre duas ou mais contas de destino em uma mesma moeda e o câmbio entre moedas na realização de transferências entre contas de diferentes moedas.
Todas essas transações estão acessíveis pelo módulo FinancialSystem

### Moedas e contas pré cadastradas
Para facilitar o uso e teste do sistema estão disponíveis 3 contas nacionais e duas internacionais e 3 moedas já cadastradas
Esses dados podem ser acessados da seguinte forma:

* Contas - Sendos os ids 1, 2 e 3 para contas nacionais, 11 para conta em Dólar Americano e 22 para conta em Euros
    ```
    FinancialSystem.Data.Accounts.find(id)
    ```

* Moedas - estando disponíveis as moedas Real ("BRL"), Dólar Americando ("USD") e Euro ("EUR")
    ```sh
    FinancialSystem.Data.Currencies.find(code)
    ```

### Transferência entre contas

* Tranferência entre contas de uma mesma moeda - recebe como parâmetros a conta a ser debitada, a conta a ser creditada e o montante
    ```sh
    FinancialSystem.transfer_from_to(sender, receiver, amount)
    ```

* Transferência em moeda estrangeira - além das contas e do valor, recebe como parâmetro a moeda da conta de destino e o taxa de câmbio da mesma para o real
    ```sh
    FinancialSystem.international_transfer(sender, receiver, amount, currency, rate)
    ```

### Rateio de valores
É possivel realizar um split financeiro entre uma conta de origem e duas ou mais contas de destino, tendo todas a mesma moeda. O valor é igualmente dividido entre as contas de destino

* Split - recebe como parâmetros a conta de origem, uma lista com as contas de destino e o valor a ser dividido
    ```sh
    FinancialSystem.split_from_to(sender, [receivers], amount)
    ```

## Visão geral
O projeto foi desenvolvido seguindo o padrão Railway, com o objetivo de assegurar que nenhuma operação inválida possa ser realizada, além do retorno de erros significativos quando há alguma falha.

### Melhorias futuras

* Rateio proporcional - operação de rateio onde cada conta de destino receba uma porcentagem específica do valor a ser rateado
* Rateio internacional - operações de rateio, simples e proporcional, entre contas de moedas diferentes