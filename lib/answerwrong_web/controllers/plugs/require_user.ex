defmodule AnswerwrongWeb.Plugs.RequireUser do
  import Plug.Conn
  import Phoenix.Controller

  alias AnswerwrongWeb.Router.Helpers

  def init(_params) do
  end

  def call(conn, _params) do
    if get_session(conn, :user_id) do
      conn
    else
      conn
      |> put_flash(:info, "Please login")
      |> redirect(to: Helpers.user_path(conn, :new))
      |> halt()
    end
  end
end
