defmodule ElixirNixExampleWeb.PageController do
  use ElixirNixExampleWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
