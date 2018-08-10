defmodule AnswerwrongWeb.Plugs.QuizSession do
  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _params) do
    conn
    |> initialise_score
    |> initialise_answer_tokens
    |> initialise_seen_answers
  end

  defp initialise_score(conn) do
    case get_session(conn, :score) do
      nil -> conn |> put_session(:score, 0)
      _ -> conn
    end
  end

  defp initialise_answer_tokens(conn) do
    case get_session(conn, :answer_tokens) do
      nil -> conn |> put_session(:answer_tokens, 0)
      _ -> conn
    end
  end

  defp initialise_seen_answers(conn) do
    case get_session(conn, :seen_questions) do
      nil -> conn |> put_session(:seen_questions, [])
      _ -> conn
    end
  end

end
