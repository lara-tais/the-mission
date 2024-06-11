defmodule IngestCSV do
  alias Mission.Repo
  alias Mission.FoodTrucks.FoodTruck
  require Logger

  def run do
    Repo.delete_all(FoodTruck)

    path = "priv/repo/data_files/Mobile_Food_Facility_Permit.csv"

    # Read the CSV file
    case File.read(path) do
      {:ok, content} ->
        parse_csv(content)

      {:error, reason} ->
        Logger.error("Failed to read file: #{inspect(reason)}")
    end
  end

  defp parse_csv(csv_content) do
    # Split the content by new lines
    lines = String.split(csv_content, "\n")

    # Extract headers from the first line
    [header_line | data_lines] = lines

    # Parse the headers
    headers = String.split(header_line, ",")

    # Process each data row
    Enum.each(data_lines, fn line ->
      process_row(line, headers)
    end)

    Logger.info("CSV ingestion completed.")
  end

  defp process_row(line, headers) do
    # Split the line into values based on commas
    values = String.split(line, ",")

    # Map the values based on headers
    row_map = Enum.zip(headers, values)
               |> Enum.into(%{})

    latitude = String.to_float(Map.get(row_map, "Latitude", "0.0"))
    longitude = String.to_float(Map.get(row_map, "Longitude", "0.0"))
    id = String.to_integer(Map.get(row_map, "locationid"))

    food_truck = %FoodTruck{
      location_id: id,
      description: Map.get(row_map, "Applicant"),
      address: Map.get(row_map, "Address"),
      status: Map.get(row_map, "Status"),
      latitude: latitude,
      longitude: longitude,
      food_items: Map.get(row_map, "FoodItems", "")
    }

    Repo.insert!(food_truck)
  rescue
    e -> Logger.error("Badly formatted row: #{inspect(e)}")
  end
end

IngestCSV.run()
