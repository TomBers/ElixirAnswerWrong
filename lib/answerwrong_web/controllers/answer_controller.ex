defmodule AnswerwrongWeb.AnswerController do
  use AnswerwrongWeb, :controller

  alias Answerwrong.Content
  alias Answerwrong.Content.Answer

  plug AnswerwrongWeb.Plugs.RequireUser when action in [:my_answers, :new]

  def index(conn, _params) do
    answers = Content.list_answers()
    render(conn, "index.html", answers: answers)
  end

  def leaderboard(conn, _params) do
    answers = Content.list_answers()
    |> Enum.sort_by(fn(ans) -> (ans.score / ans.display_count) * 100 end)
    |> Enum.reverse
    render(conn, "leaderboard.html", answers: answers)
  end

  # TODO - my answers leaderboard
  def my_answers(conn, _params) do
    user_id = get_session(conn, :user_id)
    answers = Content.list_my_answers(user_id)
    |> Enum.sort_by(fn(ans) -> (ans.score / ans.display_count) * 100 end)
    |> Enum.reverse
    render(conn, "leaderboard.html", answers: answers)
  end

  def new(conn, %{"id" => question_id}) do
    user_id = get_session(conn, :user_id)
    question = Content.get_question!(question_id)
    changeset = Content.change_answer(%Answer{question_id: question_id, user_id: user_id})
    render(conn, "new.html", changeset: changeset, question: question)
  end

  def new(conn, _params) do
    user_id = get_session(conn, :user_id)
    question = Content.get_random_question
    changeset = Content.change_answer(%Answer{question_id: question.id, user_id: user_id})
    render(conn, "new.html", changeset: changeset, question: question)
  end

  def create(conn, %{"answer" => answer_params}) do
    case Content.create_answer(answer_params) do
      {:ok, answer} ->
        conn
        |> put_flash(:info, "Answer created successfully.")
        |> redirect(to: answer_path(conn, :show, answer))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
      {:duplicate} ->
        conn
        |> put_flash(:info, "Duplicate answer")
        |> redirect(to: answer_path(conn, :new))
    end
  end

  def show(conn, %{"id" => id}) do
    answer = Content.get_answer!(id)
    render(conn, "show.html", answer: answer)
  end

  def edit(conn, %{"id" => id}) do
    answer = Content.get_answer!(id)
    changeset = Content.change_answer(answer)
    render(conn, "edit.html", answer: answer, changeset: changeset)
  end

  def update(conn, %{"id" => id, "answer" => answer_params}) do
    answer = Content.get_answer!(id)

    case Content.update_answer(answer, answer_params) do
      {:ok, answer} ->
        conn
        |> put_flash(:info, "Answer updated successfully.")
        |> redirect(to: answer_path(conn, :show, answer))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", answer: answer, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    answer = Content.get_answer!(id)
    {:ok, _answer} = Content.delete_answer(answer)

    conn
    |> put_flash(:info, "Answer deleted successfully.")
    |> redirect(to: answer_path(conn, :index))
  end
end
