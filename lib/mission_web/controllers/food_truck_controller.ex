defmodule MissionWeb.FoodTruckController do
  use MissionWeb, :controller
  alias Mission.FoodTrucks

  def index(conn, %{"vegan" => vegan, "quick" => quick, "danger" => danger}) do

  vegan = vegan == "true"
  quick = quick == "true"
  danger = danger == "true"

    food_trucks = FoodTrucks.list_food_trucks(vegan, quick, danger)
    render_food_trucks(conn, food_trucks)
  end

  def index(conn, _params) do
    food_trucks = FoodTrucks.list_food_trucks()
    render_food_trucks(conn, food_trucks)
  end

  defp render_food_trucks(conn, food_trucks) do
    food_truck_data = Enum.map(food_trucks, fn truck ->
      %{
        id: truck.id,
        description: truck.description,
        address: truck.address,
        status: truck.status,
        latitude: truck.latitude,
        longitude: truck.longitude,
        food_items: truck.food_items,
        inserted_at: truck.inserted_at,
        updated_at: truck.updated_at
      }
    end)

    json(conn, %{"data" => food_truck_data})
  end

end
