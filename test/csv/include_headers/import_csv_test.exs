defmodule Test.Csv.IncludeHeaders.ImportCsvTest do
  use ExUnit.Case
  doctest Importex

  setup_all do
    base = "#{System.cwd!()}/test/data/csv/include_headers"
    filename = "#{base}/data.csv"
    filename_2_columns = "#{base}/data_2_columns.csv"
    {:ok,
      %{
        filename: filename,
        filename_2_columns: filename_2_columns
      }
    }
  end


  test "Checking User #import_csv %{file_include_headers: true}", %{filename: filename} do
    data = filename
    |> User.import_csv(%{file_include_headers: true})

    user1 = data |> Enum.at(0)
    user2 = data |> Enum.at(1)
    user3 = data |> Enum.at(2)

    assert length(data) == 3
    assert user1 == %{
      :birth => "1951-01-01", :company_id => "1", :contract => "temporal",
      :email => "akseli.murto@example.com", :first_name => "Akseli",
      :gender => "male", :headquarters => "Bizneo@Barcelona",
      :last_name => "Murto", :role => "user", :salary => "40000",
      :username => "ticklishkoala906"
    }

    assert user2 == %{
      :birth => "1957-01-01", :company_id => "1", :contract => "temporal",
      :email => "arabic@example.com", :first_name => "آرش",
      :gender => "male", :headquarters => "Bizneo@Barcelona",
      :last_name => "علیزاده", :role => "manager", :salary => "30000",
      :username => "lazyladybug349"
    }

    assert user3 == %{
      :birth => "1950-01-01", :company_id => "1", :contract => "temporal",
      :email => "joan.betten@example.com", :first_name => "Joan",
      :gender => "male", :headquarters => "Bizneo@Madrid",
      :last_name => "Betten", :role => "user", :salary => "50000",
      :username => "beautifulrabbit988"
    }
  end

  test "Checking User only 2 columns #import_csv %{file_include_headers: true}",
    %{filename_2_columns: filename} do
    data = filename
    |> User.import_csv(%{file_include_headers: true})

    user1 = data |> Enum.at(0)
    user2 = data |> Enum.at(1)

    assert length(data) == 2
    assert user1 == %{:email => "akseli.murto@example.com", :salary => "50000"}
    assert user2 == %{:email => "joan.betten@example.com", :salary => "200000"}
  end

end
