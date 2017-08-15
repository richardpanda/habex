defmodule HabexWeb.PageController do
  use HabexWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
