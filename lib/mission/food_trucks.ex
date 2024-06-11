defmodule Mission.FoodTrucks do
  import Ecto.Query, warn: false
  alias Mission.Constants
  alias Mission.Repo
  alias Mission.FoodTrucks.FoodTruck

  @earth_radius_km 6371.0

  def list_food_trucks(vegan \\ false, quick \\ false, danger \\ false) do
    query =
      FoodTruck
      |> filter_vegan(vegan)
      |> filter_danger(danger)

    food_trucks = Repo.all(query)

    if quick do
      {office_lat, office_lon} = Constants.office_location()
      filtered_food_trucks = filter_by_distance(food_trucks, office_lat, office_lon)
      filtered_food_trucks
    else
      food_trucks
    end
  end

  defp filter_vegan(query, true) do
    from ft in query,
      where: fragment("LOWER(?)", ft.description) |> like("%%vegan%%") or
             fragment("LOWER(?)", ft.food_items) |> like("%%vegan%%")
  end

  defp filter_vegan(query, _), do: query

  defp filter_danger(query, false) do
    from ft in query,
      where: ft.status == "APPROVED"
  end

  defp filter_danger(query, true), do: query

  defp filter_by_distance(food_trucks, office_lat, office_lon) do
    Enum.filter(food_trucks, fn truck ->
      distance = calculate_distance(office_lat, office_lon, truck.latitude, truck.longitude)
      distance < 1000  # In meters
    end)
  end

  defp calculate_distance(lat1, lon1, lat2, lon2) do
    d_lat = deg2rad(lat2 - lat1)
    d_lon = deg2rad(lon2 - lon1)

    a = :math.sin(d_lat / 2) * :math.sin(d_lat / 2) +
        :math.cos(deg2rad(lat1)) * :math.cos(deg2rad(lat2)) *
        :math.sin(d_lon / 2) * :math.sin(d_lon / 2)

    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))
    distance = @earth_radius_km * c * 1000
    distance
  end

  defp deg2rad(deg), do: deg * :math.pi / 180
end
