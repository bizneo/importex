ExUnit.start()

defmodule SampleUser1 do
  use Importex

  import_fields do
    column :company_id, :integer
    column :username, :string
    column :email, :string
  end

end

defmodule SampleUser2 do
  use Importex
end
