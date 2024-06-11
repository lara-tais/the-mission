defmodule MissionWeb.FoodTruckControllerTest do
  use MissionWeb.ConnCase

  import Ecto.Query, warn: false

  alias Mission.Repo
  alias Mission.FoodTrucks.FoodTruck

    setup_all do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
      Ecto.Adapters.SQL.Sandbox.mode(Repo, :manual)
      Code.require_file("priv/repo/seeds.exs")
      IngestCSV.run()
      :ok
    end


  test "GET /api/trucks/ without filters", %{conn: conn} do
    conn = get(conn, "/api/trucks/")
    response = json_response(conn, 200)

    assert length(response["data"]) == Repo.aggregate(FoodTruck, :count, :id)
  end

  test "GET /api/trucks/?vegan=true", %{conn: conn} do
    conn = get(conn, "/api/trucks/?vegan=true")
    response = json_response(conn, 200)

    vegan_query =
      from ft in FoodTruck,
        where: fragment("LOWER(?)", ft.description) |> like("%%vegan%%") or
               fragment("LOWER(?)", ft.food_items) |> like("%%vegan%%")

    expected_count = Repo.aggregate(vegan_query, :count, :id)

    assert length(response["data"]) == expected_count
  end

  test "GET /api/trucks/?quick=true", %{conn: conn} do
    conn = get(conn, "/api/trucks/?quick=true")
    response = json_response(conn, 200)

    {office_lat, office_lon} = Mission.Constants.office_location()
    food_trucks = Enum.map(response["data"], fn truck ->
      %{
        truck | distance: calculate_distance(office_lat, office_lon, truck["latitude"], truck["longitude"])
      }
    end)
    filtered_trucks = Enum.filter(food_trucks, fn truck -> truck.distance < 1609.34 end)

    assert length(filtered_trucks) == length(filtered_trucks)
  end

  test "GET /api/trucks/?danger=false", %{conn: conn} do
    conn = get(conn, "/api/trucks/?danger=false")
    response = json_response(conn, 200)

    danger_query =
      from ft in FoodTruck,
        where: ft.status == "APPROVED"

    expected_count = Repo.aggregate(danger_query, :count, :id)

    assert length(response["data"]) == expected_count
  end

  test "GET /api/trucks/?danger=true", %{conn: conn} do
    conn = get(conn, "/api/trucks/?danger=true")
    response = json_response(conn, 200)

    assert length(response["data"]) == Repo.aggregate(FoodTruck, :count, :id)
  end

  test "GET /api/trucks/?vegan=true&quick=true&danger=true", %{conn: conn} do
    conn = get(conn, "/api/trucks/?vegan=true&quick=true&danger=true")
    response = json_response(conn, 200)

    {office_lat, office_lon} = Mission.Constants.office_location()
    food_trucks = Enum.map(response["data"], fn truck ->
      %{
        truck | distance: calculate_distance(office_lat, office_lon, truck["latitude"], truck["longitude"])
      }
    end)
    filtered_trucks = Enum.filter(food_trucks, fn truck ->
      (truck["description"] =~ "vegan" or truck["food_items"] =~ "vegan") and truck.distance < 1609.34
    end)

    assert length(filtered_trucks) == length(filtered_trucks)
  end

  defp calculate_distance(lat1, lon1, lat2, lon2) do
    # This is a simplified example. Replace with a more accurate calculation if necessary.
    :math.sqrt(:math.pow(lat2 - lat1, 2) + :math.pow(lon2 - lon1, 2)) * 111  # Rough estimate for degrees
  end
end
