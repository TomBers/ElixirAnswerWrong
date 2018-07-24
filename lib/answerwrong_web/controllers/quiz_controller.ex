defmodule AnswerwrongWeb.QuizController do
  use AnswerwrongWeb, :controller
  alias Answerwrong.Content

  plug AnswerwrongWeb.Plugs.RequireUser when action in [:quiz]
  plug AnswerwrongWeb.Plugs.QuizSession when action in [:quiz, :quiz_answer]

  def quiz(conn, _params) do
    seen_questions = get_session(conn, :seen_questions)
    {conn, encoded_answer_id} = set_answer_id(conn)

    question = get_unique_question(seen_questions)
    Content.update_question_view_count(question.id)
    answers = Content.get_all_answers_for_question(question.id) |> Enum.map(fn(answer) -> %{id: Base.encode64("#{answer.id}"), text: answer.text} end)
    all_ans = List.insert_at(answers, 0, %{id: encoded_answer_id, text: question.answer})

    # Sort out the session - record the questions seen this session
    {conn, number_seen_questions} = set_session(conn, question, seen_questions)

    render(conn, "quiz.html", question_id: question.id, question: question.question, answers: Enum.shuffle(all_ans), question_number: number_seen_questions, user_id: get_session(conn, :user_id))
  end

  defp get_unique_question(seen_questions) do
    question = Content.get_random_question
    case Enum.member?(seen_questions, question.id) do
      true -> get_unique_question(seen_questions)
      false -> question
    end
  end

  def winner(conn, _params) do
    render conn, "winner.html", score: get_session(conn, :score)
  end

  defp set_answer_id(conn) do
    rnd = Enum.random(1..1000)
    {put_session(conn, :answer_id, "#{-rnd}"), Base.encode64("#{-rnd}")}
  end

  def play_again(conn, _params) do
    conn
    |> put_session(:seen_questions, [])
    |> put_session(:score, 0)
    |> redirect(to: quiz_path(conn, :quiz))
  end

  defp set_session(conn, question, seen_questions) do
    conn = put_session(conn, :seen_questions, List.insert_at(seen_questions, 0, question.id))
    {conn, length(get_session(conn, :seen_questions))}
  end

  defp update_quiz_score(conn) do
    put_session(conn, :score, get_session(conn, :score) + 1)
  end

  def quiz_answer(conn, %{"_csrf_token" => _, "_utf8" => _, "answer" => encoded_answer_id}) do
    {status, answer_id} = Base.decode64(encoded_answer_id)

    if answer_id != get_session(conn, :answer_id) do
      Content.add_to_answer_score(answer_id)
    else
      conn = update_quiz_score(conn)
    end

    redirect_quiz(conn, get_session(conn, :seen_questions))
  end

  def quiz_answer(conn, %{"_csrf_token" => _, "_utf8" => _}) do
    redirect_quiz(conn, get_session(conn, :seen_questions))
  end


  defp redirect_quiz(conn, seen_questions) when length(seen_questions) >= 5 do
    redirect(conn, to: quiz_path(conn, :winner))
  end

  defp redirect_quiz(conn, seen_questions) do
    redirect(conn, to: quiz_path(conn, :quiz))
  end

end
