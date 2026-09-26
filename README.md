# Sistema de Empréstimo de Livros

## Sobre o projeto

A aplicação consiste em um sistema web para gestão de empréstimo de livros em uma biblioteca. O objetivo do projeto é demonstrar a integração de objetos avançados de banco de dados — **Views**, **Functions** e **Procedures** — com a camada de persistência e regras de negócio do Ruby on Rails via ActiveRecord.

O sistema resolve o controle de disponibilidade do acervo em tempo real, previne condições de corrida durante o processo de empréstimo através de locks de escrita no PostgreSQL e efetua o cálculo automatizado de multas por atraso nas devoluções.

## Tecnologias utilizadas

```
Ruby 3.x
Ruby on Rails 8
PostgreSQL 11+
HTML / CSS
```

## Banco de dados

* **SGBD utilizado:** PostgreSQL
* **Principais tabelas:**
  * `users`: Armazena os dados dos leitores/usuários (`id`, `name`, `email`).
  * `books`: Registra os exemplares do acervo (`id`, `title`, `author`, `isbn`, `total_copies`, `available_copies`).
  * `loans`: Contabiliza as transações de empréstimo (`id`, `user_id`, `book_id`, `borrowed_at`, `due_date`, `returned_at`).
* **View criada:** 
  * `book_catalog_summaries`: Consolida as informações de títulos, leituras acumuladas, exemplares totais/disponíveis e o status do item (`Disponível` ou `Esgotado`) diretamente em tempo real.
* **Function criada:** 
  * `calculate_late_fee(p_due_date, p_returned_at, p_daily_rate)`: Função de cálculo que recebe a data de vencimento e devolução para computar dinamicamente a taxa diária de multa por atraso.
* **Procedure criada:** 
  * `borrow_book_procedure(p_user_id, p_book_id, p_days_to_return)`: Stored Procedure transacional que executa um lock pessimista (`FOR UPDATE`) no livro, verifica o saldo de estoque disponível, decrementa a quantidade e insere o novo registro de empréstimo na tabela `loans` de forma atômica.

## Como executar

1. **Clonar o repositório e acessar a pasta do projeto:**
   ```bash
   git clone <URL_DO_REPOSITORIO>
   cd book_lending
   ```

2. **Instalar as dependências do Rails:**
   ```bash
   bundle install
   ```

3. **Configurar e popular o banco de dados:**
   Certifique-se de que o serviço do PostgreSQL esteja rodando localmente e execute:
   ```bash
   bin/rails db:create db:migrate db:seed
   ```

4. **Iniciar o servidor web:**
   ```bash
   bin/rails server
   ```

5. **Acessar a aplicação:**
   Abra o navegador e acesse `http://localhost:3000`.
