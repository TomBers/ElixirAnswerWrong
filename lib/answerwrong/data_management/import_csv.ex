defmodule Answerwrong.ImportCsv do

  alias Answerwrong.Content

  def import(filepath) do
    File.stream!(filepath) |>
    CSV.decode |>
    Enum.map fn row ->
      process_row row
    end
  end

  defp process_row({:ok, row}) do
    question = Enum.at(row, 0)
    correct_answer = Enum.at(row, 1)

    case Content.create_question(%{answer: correct_answer, question: question}) do
      {:ok, question} -> insert_wrong_answers(question.id, Enum.slice(row, 2..length(row)))
      {:error, %Ecto.Changeset{} = changeset} -> IO.puts("Error")
    end
  end

  defp insert_wrong_answers(qnid, answers) do
    answers
    |> Enum.map fn ans ->
      insert_wrong_answer(qnid, ans)
    end
  end

  defp insert_wrong_answer(qnid, answer) do
    Content.create_answer_from_csv(%{text: answer, question_id: qnid, user_id: "1"})
  end
end
