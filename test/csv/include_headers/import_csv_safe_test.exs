defmodule Test.Csv.IncludeHeaders.ImportCsvSafeTest do
  use ExUnit.Case
  doctest Importex

  setup_all do
    base = "#{System.cwd!()}/test/data/csv/include_headers"
    filename = "#{base}/data.csv"
    filename_invalid_columns = "#{base}/data_invalid_columns.csv"
    {:ok,
      %{
        filename: filename,
        filename_invalid_columns: filename_invalid_columns
      }
    }
  end


  test "Checking User #import_csv_safe %{file_include_headers: true}", %{filename: filename} do
    data = filename
    |> User.import_csv_safe(%{file_include_headers: true})

    user1 = data |> Enum.at(0)
    user2 = data |> Enum.at(1)
    user3 = data |> Enum.at(2)

    assert length(data) == 3
    assert user1 == %{
      :birth => "1951-01-01", :company_id => 1, :contract => "temporal",
      :email => "akseli.murto@example.com", :first_name => "Akseli",
      :gender => "male", :headquarters => "Bizneo@Barcelona",
      :last_name => "Murto", :role => 1, :salary => 40000,
      :username => "ticklishkoala906"
    }

    assert user2 == %{
      :birth => "1957-01-01", :company_id => 1, :contract => "temporal",
      :email => "arabic@example.com", :first_name => "آرش",
      :gender => "male", :headquarters => "Bizneo@Barcelona",
      :last_name => "علیزاده", :role => 0, :salary => 30000,
      :username => "lazyladybug349"
    }

    assert user3 == %{
      :birth => "1950-01-01", :company_id => 1, :contract => "temporal",
      :email => "joan.betten@example.com", :first_name => "Joan",
      :gender => "male", :headquarters => "Bizneo@Madrid",
      :last_name => "Betten", :role => 1, :salary => 50000,
      :username => "beautifulrabbit988"
    }
  end

  # In this test the csv contains 4 columns, (email;unkwnown1;money;unknown2)
  # but only email and money(as salary) are in User import_fields,  so unkwnown1
  # and unkwnown2 must be removed.
  test "Checking User only 2 valid columns, the rest must be filtered",
    %{filename_invalid_columns: filename} do
    data = filename
    |> User.import_csv_safe(%{file_include_headers: true})

    user1 = data |> Enum.at(0)
    user2 = data |> Enum.at(1)

    assert length(data) == 2
    assert user1 == %{:email => "akseli.murto@example.com", :salary => 50000,
    :gender => "male"}
    assert user2 == %{:email => "joan.betten@example.com", :salary => 200000,
    errors: [gender: "'invalid_gender' is not in the list"]}
  end

end
