defmodule MissionWeb.Router do
  use MissionWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    # Serve static files
    plug Plug.Static,
      at: "/",
      from: :mission,
      gzip: false,
      only: ~w(css js images fonts favicon.ico)
  end

  scope "/api", MissionWeb do
    pipe_through :api

    get "/trucks", FoodTruckController, :index
  end

  scope "/", MissionWeb do
    pipe_through :browser

    # Redirect to static index.html for the root path
    get "/", PageController, :serve_index
  end
end
