defmodule LiveViewListsWeb.PageController do
  use LiveViewListsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
