defmodule Mission.FoodTrucks.FoodTruck do
  use Ecto.Schema
  import Ecto.Changeset

  schema "food_trucks" do
    field :location_id, :integer
    field :description, :string
    field :address, :string
    field :status, :string
    field :latitude, :float
    field :longitude, :float
    field :food_items, :string
    timestamps()
  end

  @doc false
  def changeset(food_truck, attrs) do
    food_truck
    |> cast(attrs, [:description, :address, :status, :latitude, :longitude, :food_items])
    |> validate_required([:description, :address, :status, :latitude, :longitude])
  end
end
