# Importex

**Importex is a wrapper to import files (by now csv), checking data types and casting.**

## Installation

Add `importex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:importex, "~> 0.1.0"}]
end
```

## How to use it

Let's imagine that we want to import users from a cvs file and we have a `User` module in our project.

We need to `use Importex` in that module as follow:

```elixir
defmodule User do
  use Importex
 end
```

Now we should specified what are the fields needed in our `User` model to import users:

```elixir
defmodule User do
  use Importex

  import_fields do
    column :email, :email
    column :first_name, :string
    column :second_name, :string, as: :last_name
    column :role, :map, values: [{"manager", 0}, {"user", 1}]
    column :gender, :list, values: ["male", "female"]
    column :company_id, :integer
    column :contract, :string
    column :money, :integer, as: :salary
  end
end
```

Importex will add to your `User` model two methods to import csv, `import_csv`
and `import_csv_safe`:

#### Examples:

```elixir
iex> User.import_csv("data.csv")
````
```elixir
[%{:birth => "1951-01-01", :company_id => "1", :contract => "temporal", :email => "akseli.murto@example.com", :first_name => "Akseli", :gender => "male", :last_name => "Murto", :role => "0", :salary => "40000"}]
```
