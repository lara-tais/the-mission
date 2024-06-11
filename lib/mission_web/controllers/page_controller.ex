defmodule MissionWeb.PageController do
  use MissionWeb, :controller

  def serve_index(conn, _params) do
    index_path = "priv/static/index.html"
    index_content = File.read!(index_path)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, index_content)
  end
end
