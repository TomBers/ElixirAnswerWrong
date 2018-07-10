defmodule AnswerwrongWeb.PageController do
  use AnswerwrongWeb, :controller
  alias Answerwrong.Content

  def index(conn, _params) do
    render conn, "index.html"
  end

  def quiz(conn, _params) do
    question = Content.get_random_question
    IO.inspect(question)
    answers = Content.get_all_answers_for_question(question.id)
    # answers = question.answers
    IO.inspect(answers)
    render(conn, "quiz.html", question_id: question.id, question: question.question, answers: answers)
  end
end
