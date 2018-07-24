defmodule AnswerwrongWeb.Plugs.QuizSession do
  import Plug.Conn
  import Phoenix.Controller

  alias AnswerwrongWeb.Router.Helpers

  def init(_params) do
  end

  def call(conn, _params) do
    conn
    |> initialise_score
    |> initialise_seen_answers
  end

  defp initialise_score(conn) do
    if get_session(conn, :score) do
      conn
    else
      conn
      |> put_session(:score, 0)
    end
  end

  defp initialise_seen_answers(conn) do
    if get_session(conn, :seen_questions) do
      conn
    else
      conn
      |> put_session(:seen_questions, [])
    end
  end

end
