defmodule Answerwrong.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias Answerwrong.Repo
  alias Ecto.Multi

  alias Answerwrong.Content.Question

  @doc """
  Returns the list of questions.

  ## Examples

      iex> list_questions()
      [%Question{}, ...]

  """
  def list_questions do
    Repo.all(Question)
  end

  def get_random_question do
    random_question = from(qn in Question, order_by: fragment("RANDOM()"), limit: 1)
    |> Repo.all
    |> List.first
  end

  def update_question_view_count(question_id) do
    question = get_question!(question_id)
    new_count = question.display_count + 1
    update_question(question, %{display_count: new_count})
  end

  @doc """
  Gets a single question.

  Raises `Ecto.NoResultsError` if the Question does not exist.

  ## Examples

      iex> get_question!(123)
      %Question{}

      iex> get_question!(456)
      ** (Ecto.NoResultsError)

  """
  def get_question!(id), do: Repo.get!(Question, id)

  @doc """
  Creates a question.

  ## Examples

      iex> create_question(%{field: value})
      {:ok, %Question{}}

      iex> create_question(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_question(attrs \\ %{}) do
    %Question{}
    |> Question.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a question.

  ## Examples

      iex> update_question(question, %{field: new_value})
      {:ok, %Question{}}

      iex> update_question(question, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_question(%Question{} = question, attrs) do
    question
    |> Question.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Question.

  ## Examples

      iex> delete_question(question)
      {:ok, %Question{}}

      iex> delete_question(question)
      {:error, %Ecto.Changeset{}}

  """
  def delete_question(%Question{} = question) do
    Repo.delete(question)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking question changes.

  ## Examples

      iex> change_question(question)
      %Ecto.Changeset{source: %Question{}}

  """
  def change_question(%Question{} = question) do
    Question.changeset(question, %{})
  end

  alias Answerwrong.Content.Answer

  @doc """
  Returns the list of answers.

  ## Examples

      iex> list_answers()
      [%Answer{}, ...]

  """
  def list_answers do
    Repo.all(Answer)
  end

  def leaderboard_answers do
    Repo.all from ans in Answer,
      join: usr in assoc(ans, :user),
      join: qn in assoc(ans, :question),
      where: ans.score >= 1,
      preload: [user: usr],
      preload: [question: qn]
  end

  def list_my_answers(user_id) do
    Repo.all from ans in Answer,
      join: qn in assoc(ans, :question),
      where: ans.user_id == ^user_id and ans.score >= 1,
      preload: [question: qn]
  end

  @doc """
  Gets a single answer.

  Raises `Ecto.NoResultsError` if the Answer does not exist.

  ## Examples

      iex> get_answer!(123)
      %Answer{}

      iex> get_answer!(456)
      ** (Ecto.NoResultsError)

  """

  def get_all_answers_for_question(id) do
    choosen_answers = from(ans in Answer, where: ans.question_id == ^id, order_by: fragment("RANDOM()"), limit: 3)
    |> Repo.all

    ids = choosen_answers |> Enum.reduce([], fn(ans, acc) -> [ans.id | acc] end)

    from(ans in Answer, where: ans.id in ^ids)
    |> Repo.update_all([inc: [display_count: 1]], returning: true)
    choosen_answers
  end

  def add_to_answer_score(id) do
    answer = get_answer!(id)
    new_score = answer.score + 1
    update_answer(answer, %{score: new_score})
  end

  def get_answer!(id), do: Repo.get!(Answer, id)

  @doc """
  Creates a answer.

  ## Examples

      iex> create_answer(%{field: value})
      {:ok, %Answer{}}

      iex> create_answer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_answer_from_csv(attrs \\ %{}) do
    %Answer{}
    |> Answer.changeset(attrs)
    |> Repo.insert()
  end

  def create_answer(attrs \\ %{}) do
    qn = get_question!(Map.get(attrs, "question_id"))
    user_ans = Map.get(attrs, "text")

    if !is_duplicate(qn.answer, user_ans) do
      %Answer{}
      |> Answer.changeset(attrs)
      |> Repo.insert()
    else
       {:duplicate}
    end
  end

  defp is_duplicate(correct_answer, user_answer) do
    String.replace(correct_answer, " ", "", global: true) |> String.downcase == String.replace(user_answer, " ", "", global: true) |> String.downcase
  end

  @doc """
  Updates a answer.

  ## Examples

      iex> update_answer(answer, %{field: new_value})
      {:ok, %Answer{}}

      iex> update_answer(answer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_answer(%Answer{} = answer, attrs) do
    answer
    |> Answer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Answer.

  ## Examples

      iex> delete_answer(answer)
      {:ok, %Answer{}}

      iex> delete_answer(answer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_answer(%Answer{} = answer) do
    Repo.delete(answer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking answer changes.

  ## Examples

      iex> change_answer(answer)
      %Ecto.Changeset{source: %Answer{}}

  """
  def change_answer(%Answer{} = answer) do
    Answer.changeset(answer, %{})
  end
end
