ExUnit.start()

defmodule BasicUser do
  use Importex
  import_fields do
    column :email, :email
    column :first_name, :string
    column :last_name, :string
    column :birth, :string
    column :role, :string
    column :gender, :string
    column :username, :string
    column :company_id, :integer
    column :contract, :string
    column :salary, :integer
    column :headquarters, :string
  end
end

defmodule User do
  use Importex
  import_fields do
    column :email, :email
    column :first_name, :string
    column :second_name, :string, as: :last_name
    column :birth, :string
    column :role, :map, values: [{"manager", 0}, {"user", 1}]
    column :gender, :list, values: ["male", "female"]
    column :username, :string
    column :company_id, :integer
    column :contract, :string
    column :money, :integer, as: :salary
    column :headquarters, :string
  end
end
