defmodule AnswerwrongWeb.QuizController do
  use AnswerwrongWeb, :controller
  alias Answerwrong.Content

  def quiz(conn, _params) do
    seen_questions = get_session(conn, :seen_questions)
    {conn, encoded_answer_id} = set_answer_id(conn)

    question = Content.get_random_question
    Content.update_question_view_count(question.id)
    answers = Content.get_all_answers_for_question(question.id) |> Enum.map(fn(answer) -> %{id: Base.encode64("#{answer.id}"), text: answer.text} end)
    all_ans = List.insert_at(answers, 0, %{id: encoded_answer_id, text: question.answer})

    # Sort out the session - record the questions seen this session
    {conn, number_seen_questions} = set_session(conn, question, seen_questions)

    if number_seen_questions <= 5 do
      render(conn, "quiz.html", question_id: question.id, question: question.question, answers: Enum.shuffle(all_ans), question_number: number_seen_questions)
    else
       render conn, "winner.html", score: get_session(conn, :score)
    end
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
    if seen_questions do
      conn = put_session(conn, :seen_questions, List.insert_at(seen_questions, 0, question.id))
    else
      conn = put_session(conn, :seen_questions, [question.id])
    end
    {conn, length(get_session(conn, :seen_questions))}
  end

  defp update_quiz_score(conn) do
    score = get_session(conn, :score)
    if score do
      conn = put_session(conn, :score, score + 1)
    else
      conn = put_session(conn, :score, 1)
    end
  end

  def quiz_answer(conn, %{"_csrf_token" => _, "_utf8" => _, "answer" => encoded_answer_id}) do
    {status, answer_id} = Base.decode64(encoded_answer_id)
    if answer_id != get_session(conn, :answer_id) do
      Content.add_to_answer_score(answer_id)
    else
      conn = update_quiz_score(conn)
    end
    redirect(conn, to: quiz_path(conn, :quiz))
  end
end
