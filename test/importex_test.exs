defmodule ImportexTest do
  use ExUnit.Case
  doctest Importex

  setup_all do
    filename = "#{System.cwd!()}/test/data/users.csv"
    {:ok,
      %{
        data1: SampleUser1.import(filename),
        data2: SampleUser2.import(filename),
        data3: SampleUser3.import(filename, %{headers: [id: :integer]} )
      }
    }
  end


  test "SampleUser1 checks (3 header keys)", %{data1: data} do
    user1 = data |> List.first

    assert length(data) == 2
    assert user1.id == "1"
    assert user1.username == "john"
    assert user1.email == "john@email.com"
  end

  test "SampleUser2 checks (3 header keys)", %{data2: data} do
    user2 = data |> List.last

    assert length(data) == 2
    assert user2.id == "2"
    assert user2.username == "ana"
    assert user2.email == "ana@email.com"
    assert user2.city == "madrid"
  end

  test "SampleUser3 checks (custom header)", %{data3: data} do
    user3 = data |> List.first

    total_keys = user3
    |> Map.keys
    |> length
    #There is only one key
    assert length(data) == 2
    assert total_keys == 1
    assert user3.id == "1"
  end


end
