defmodule ElixirjujuTest do
  use ExUnit.Case
  require Elixirjuju

  test "login gives us the right structure" do
    assert(
    "{\"Type\": \"Admin\", \"Request\": \"Login\", \"Params\": {\"AuthTag\": \"user\", \"Password\": \"password\"}}"
    ==
    Elixirjuju.login("user", "password")
    )
  end

  test "watch all gives us the right structure" do
    assert(
    "{\"Type\": \"Client\", \"Request\": \"WatchAll\", \"Params\": {}}"
    ==
    Elixirjuju.watch_all()
    )
  end

  test "next gives us the right structure" do
    assert(
    "{\"Type\": \"AllWatcher\", \"Request\": \"Next\", \"Id\": \"1\"}"
    ==
    Elixirjuju.next()
    )
  end

  test "deploy gives us the right structure" do
    #Needs improving
  end

  test "destroy service gives us the right structure" do
    assert(
    "{ \"Type\": \"Client\", \"Request\": \"ServiceDestroy\", \"Params\": { \"ServiceName\": \"service_name\"}}"
    ==
    Elixirjuju.destroy_service("service_name")
    )
  end

  test "add relation gives us the right structure" do
    assert(
    "{\"Type\": \"Client\", \"Request\": \"AddRelation\", \"Params\": { \"Endpoints\": [\"serviceA\", \"serviceB\"]}}"
    ==
    Elixirjuju.add_relation("serviceA", "serviceB")
    )
  end

  test "add unit gives us the right structure" do
    assert(
    "{\"Type\": \"Client\", \"Request\": \"AddServiceUnits\", \"Params\": { \"ServiceName\": \"service_name\", \"NumUnits\": 2}}"
    ==
    Elixirjuju.add_unit("service_name", 2)
    )
  end

  test "remove unit gives us the right structure" do
    assert(
    "{\"Type\": \"Client\", \"Request\": \"DestroyServiceUnits\", \"Params\": { \"UnitNames\": [\"unit_names\"]}}"
    ==
    Elixirjuju.remove_units(["unit_names"])
    )
  end
end
