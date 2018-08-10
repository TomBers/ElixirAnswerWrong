defmodule AnswerwrongWeb.Plugs.CheckAnswerToken do
  import Plug.Conn
  import Phoenix.Controller

  alias AnswerwrongWeb.Router.Helpers

  def init(_params) do
  end

  def call(conn, _params) do
    if get_session(conn, :answer_tokens) > 0 do
      conn
    else
      conn
      |> put_flash(:info, "No tokens")
      |> redirect(to: Helpers.quiz_path(conn, :quiz))
      |> halt()
    end
  end
end
