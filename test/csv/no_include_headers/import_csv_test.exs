defmodule Test.Cvs.NoIncludeHeaders.ImportCvsTest do
  use ExUnit.Case
  doctest Importex

  setup_all do
    base = "#{System.cwd!()}/test/data/csv/no_include_headers"
    filename = "#{base}/data.csv"
    {:ok, %{filename: filename}}
  end


  test "Checking BasicUser #import_csv", %{filename: filename} do
    data = filename
    |> BasicUser.import_csv

    user1 = data |> Enum.at(0)
    user2 = data |> Enum.at(1)
    user3 = data |> Enum.at(2)

    assert length(data) == 3
    assert user1 == %{
      "birth" => "1951-01-01", "company_id" => "1", "contract" => "temporal",
      "email" => "akseli.murto@example.com", "first_name" => "Akseli",
      "gender" => "male", "headquarters" => "Bizneo@Barcelona",
      "last_name" => "Murto", "role" => "user", "salary" => "40000",
      "username" => "ticklishkoala906"
    }

    assert user2 == %{
      "birth" => "1957-01-01", "company_id" => "1", "contract" => "temporal",
      "email" => "arabic@example.com", "first_name" => "آرش",
      "gender" => "male", "headquarters" => "Bizneo@Barcelona",
      "last_name" => "علیزاده", "role" => "manager", "salary" => "30000",
      "username" => "lazyladybug349"
    }

    assert user3 == %{
      "birth" => "1950-01-01", "company_id" => "1", "contract" => "temporal",
      "email" => "joan.betten@example.com", "first_name" => "Joan",
      "gender" => "male", "headquarters" => "Bizneo@Madrid",
      "last_name" => "Betten", "role" => "user", "salary" => "50000",
      "username" => "beautifulrabbit988"
    }
  end

end
