defmodule Test.Csv.NoIncludeHeaders.ImportCsvSafeTest do
  use ExUnit.Case
  doctest Importex

  setup_all do
    base = "#{System.cwd!()}/test/data/csv/no_include_headers"
    filename = "#{base}/data.csv"
    filename_2_columns = "#{base}/data_2_columns.csv"
    filename_data_incomplete = "#{base}/data_incomplete.csv"
    {:ok,
      %{
        filename: filename,
        filename_2_columns: filename_2_columns,
        filename_data_incomplete: filename_data_incomplete
      }
    }
  end

  test "User #import_csv_safe", %{filename: filename} do
    data = filename
    |> User.import_csv_safe

    user1 = data |> Enum.at(0)
    user2 = data |> Enum.at(1)
    user3 = data |> Enum.at(2)

    assert length(data) == 3
    assert user1 == %{birth: "1951-01-01", company_id: 1, contract: "temporal",
      email: "akseli.murto@example.com", first_name: "Akseli", gender: "male",
      headquarters: "Bizneo@Barcelona", last_name: "Murto", role: 1,
      salary: 40000, username: "ticklishkoala906"
    }
    assert user2 == %{birth: "1957-01-01", company_id: 1, contract: "temporal",
      email: "arabic@example.com",
      first_name: "آرش", gender: "male", headquarters: "Bizneo@Barcelona",
      last_name: "علیزاده", role: 0, salary: 30000,
      username: "lazyladybug349"
    }
    assert user3 == %{birth: "1950-01-01", company_id: 1, contract: "temporal",
      email: "joan.betten@example.com", first_name: "Joan", gender: "male",
      headquarters: "Bizneo@Madrid", last_name: "Betten", role: 1,
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

  test "User #import_csv_safe checking default values", %{filename_data_incomplete: filename_data_incomplete} do
    data = filename_data_incomplete
    |> User.import_csv_safe

    # User2 has not salary and it's set to defaul:0
    # User3 has not and it's set to user (0)

    user1 = data |> Enum.at(0)
    user2 = data |> Enum.at(1)
    user3 = data |> Enum.at(2)

    assert length(data) == 3
    assert user1 == %{birth: "1951-01-01", company_id: 1, contract: "temporal",
      email: "akseli.murto@example.com", first_name: "Akseli", gender: "male",
      headquarters: "Bizneo@Barcelona", last_name: "Murto", role: 1,
      salary: 40000, username: "ticklishkoala906"
    }
    assert user2 == %{birth: "1957-01-01", company_id: 1, contract: "temporal",
      email: "arabic@example.com",
      first_name: "آرش", gender: "male", headquarters: "Bizneo@Barcelona",
      last_name: "علیزاده", role: 0, salary: 0,
      username: "lazyladybug349"
    }
    assert user3 == %{birth: "1950-01-01", company_id: 1, contract: "temporal",
      email: "joan.betten@example.com", first_name: "Joan", gender: "male",
      headquarters: "Bizneo@Madrid", last_name: "Betten", role: 1,
      salary: 50000, username: "beautifulrabbit988"
    }
  end

end
