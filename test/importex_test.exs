defmodule ImportexTest do
  use ExUnit.Case
  doctest Importex

  setup_all do
    filename = "#{System.cwd!()}/test/data/users.csv"
    filename_with_headers = "#{System.cwd!()}/test/data/users_with_headers.csv"
    {:ok,
      %{
        filename: filename,
        data1: SampleUser1.import_csv(filename),
        data2: SampleUser1.import_csv_safe(filename),
        data3: SampleUser1.import_csv(filename_with_headers, %{include_headers: true}),
        data4: SampleUser1.import_csv_safe(filename_with_headers, %{include_headers: true}),
      }
    }
  end


  test "SampleUser1 #import_csv", %{data1: data} do
    user1 = data |> List.first

    assert length(data) == 2
    assert user1 == %{"company_id" => "1", "email" => "john@email.com", "username" => "john"}
  end

  test "SampleUser1 #import_csv_safe", %{data2: data} do
    user2 = data |> List.last

    assert length(data) == 2
    assert user2 == %{company_id: 2, email: "ana@email.com", username: "ana"}
  end

  test "SampleUser1 #import_csv , include_headers: true", %{data3: data} do
    user2 = data |> List.last

    assert length(data) == 2
    assert user2 == %{"company_id" => "2", "email" => "ana@email.com", "name" => "ana"}
  end

  test "SampleUser1 #import_csv_safe , include_headers: true", %{data4: data} do
    user2 = data |> List.last

    assert length(data) == 2
    assert user2 == %{company_id: 2, email: "ana@email.com"}
  end

  test "SampleUser1 #import_csv with custom headers", %{filename: filename} do
    headers = [{:id, :integer}, {:first_name, :string}, {:email, :email}]
    data    = SampleUser1.import_csv(filename, %{headers: headers})
    user1   = data |> List.first

    assert length(data) == 2
    assert user1 == %{"email" => "john@email.com" , "id" => "1", "first_name" => "john"}
  end

  test "SampleUser1 #import_csv_safe with custom headers", %{filename: filename} do
    headers = [{:id, :integer}, {:first_name, :string}, {:email, :email}]
    data    = SampleUser1.import_csv_safe(filename, %{headers: headers})
    user1   = data |> List.first

    assert length(data) == 2
    assert user1 == %{email: "john@email.com" , id: 1, first_name: "john"}
  end

end
