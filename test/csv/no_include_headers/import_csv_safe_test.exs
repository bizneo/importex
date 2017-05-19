defmodule Test.Cvs.NoIncludeHeaders.ImportCvsSafeTest do
  use ExUnit.Case
  doctest Importex

  setup_all do
    base = "#{System.cwd!()}/test/data/csv/no_include_headers"
    filename = "#{base}/data.csv"
    filename_2_columns = "#{base}/data_2_columns.csv"
    {:ok,
      %{
        filename: filename,
        filename_2_columns: filename_2_columns
      }
    }
  end


  test "BasicUser #import_csv_safe", %{filename: filename} do
    data = filename
    |> BasicUser.import_csv_safe

    user1 = data |> Enum.at(0)
    user2 = data |> Enum.at(1)
    user3 = data |> Enum.at(2)

    assert length(data) == 3
    assert user1 == %{birth: "1951-01-01", company_id: 1, contract: "temporal",
      email: "akseli.murto@example.com", first_name: "Akseli", gender: "male",
      headquarters: "Bizneo@Barcelona", last_name: "Murto", role: "user",
      salary: 40000, username: "ticklishkoala906"
    }
    assert user2 == %{birth: "1957-01-01", company_id: 1, contract: "temporal",
      email: "arabic@example.com",
      first_name: "آرش", gender: "male", headquarters: "Bizneo@Barcelona",
      last_name: "علیزاده", role: "manager", salary: 30000,
      username: "lazyladybug349"
    }
    assert user3 == %{birth: "1950-01-01", company_id: 1, contract: "temporal",
      email: "joan.betten@example.com", first_name: "Joan", gender: "male",
      headquarters: "Bizneo@Madrid", last_name: "Betten", role: "user",
      salary: 50000, username: "beautifulrabbit988"
    }
  end


  test "BasicUser #import_csv_safe with custom columns", %{filename_2_columns: filename} do
    columns = [{:custom_email, :email}, {:custom_money, :string}]
    data    = filename |> BasicUser.import_csv_safe(%{columns: columns})
    user1   = data |> List.first

    assert length(data) == 2
    assert user1 == %{custom_email: "akseli.murto@example.com" , custom_money: "50000"}
  end

end