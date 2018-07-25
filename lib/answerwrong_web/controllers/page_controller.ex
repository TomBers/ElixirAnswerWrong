defmodule AnswerwrongWeb.PageController do
  use AnswerwrongWeb, :controller
  alias Answerwrong.Content

  def index(conn, _params) do
    render conn, "index.html"
  end
end
