defmodule Mission.Repo.Migrations.CreateFoodTrucks do
  use Ecto.Migration

  def change do
    create table(:food_trucks) do
      add :location_id, :integer
      add :description, :string
      add :address, :string
      add :status, :string
      add :latitude, :float
      add :longitude, :float
      add :food_items, :string

      timestamps()
    end
  end
end
