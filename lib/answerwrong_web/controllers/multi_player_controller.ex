defmodule AnswerwrongWeb.MultiPlayerController do
  use AnswerwrongWeb, :controller

  def room(conn, _params) do
    user_id = get_session(conn, :current_user_id)
    token = Phoenix.Token.sign(conn, "user token", user_id)

    render assign(conn, :user_token, token), "index.html"
  end

end
