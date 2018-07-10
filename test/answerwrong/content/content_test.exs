defmodule Answerwrong.ContentTest do
  use Answerwrong.DataCase

  alias Answerwrong.Content

  describe "questions" do
    alias Answerwrong.Content.Question

    @valid_attrs %{answer: "some answer", display_count: 42, question: "some question"}
    @update_attrs %{answer: "some updated answer", display_count: 43, question: "some updated question"}
    @invalid_attrs %{answer: nil, display_count: nil, question: nil}

    def question_fixture(attrs \\ %{}) do
      {:ok, question} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Content.create_question()

      question
    end

    test "list_questions/0 returns all questions" do
      question = question_fixture()
      assert Content.list_questions() == [question]
    end

    test "get_question!/1 returns the question with given id" do
      question = question_fixture()
      assert Content.get_question!(question.id) == question
    end

    test "create_question/1 with valid data creates a question" do
      assert {:ok, %Question{} = question} = Content.create_question(@valid_attrs)
      assert question.answer == "some answer"
      assert question.display_count == 42
      assert question.question == "some question"
    end

    test "create_question/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_question(@invalid_attrs)
    end

    test "update_question/2 with valid data updates the question" do
      question = question_fixture()
      assert {:ok, question} = Content.update_question(question, @update_attrs)
      assert %Question{} = question
      assert question.answer == "some updated answer"
      assert question.display_count == 43
      assert question.question == "some updated question"
    end

    test "update_question/2 with invalid data returns error changeset" do
      question = question_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_question(question, @invalid_attrs)
      assert question == Content.get_question!(question.id)
    end

    test "delete_question/1 deletes the question" do
      question = question_fixture()
      assert {:ok, %Question{}} = Content.delete_question(question)
      assert_raise Ecto.NoResultsError, fn -> Content.get_question!(question.id) end
    end

    test "change_question/1 returns a question changeset" do
      question = question_fixture()
      assert %Ecto.Changeset{} = Content.change_question(question)
    end
  end

  describe "answers" do
    alias Answerwrong.Content.Answer

    @valid_attrs %{display_count: 42, score: 42, text: "some text"}
    @update_attrs %{display_count: 43, score: 43, text: "some updated text"}
    @invalid_attrs %{display_count: nil, score: nil, text: nil}

    def answer_fixture(attrs \\ %{}) do
      {:ok, answer} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Content.create_answer()

      answer
    end

    test "list_answers/0 returns all answers" do
      answer = answer_fixture()
      assert Content.list_answers() == [answer]
    end

    test "get_answer!/1 returns the answer with given id" do
      answer = answer_fixture()
      assert Content.get_answer!(answer.id) == answer
    end

    test "create_answer/1 with valid data creates a answer" do
      assert {:ok, %Answer{} = answer} = Content.create_answer(@valid_attrs)
      assert answer.display_count == 42
      assert answer.score == 42
      assert answer.text == "some text"
    end

    test "create_answer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_answer(@invalid_attrs)
    end

    test "update_answer/2 with valid data updates the answer" do
      answer = answer_fixture()
      assert {:ok, answer} = Content.update_answer(answer, @update_attrs)
      assert %Answer{} = answer
      assert answer.display_count == 43
      assert answer.score == 43
      assert answer.text == "some updated text"
    end

    test "update_answer/2 with invalid data returns error changeset" do
      answer = answer_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_answer(answer, @invalid_attrs)
      assert answer == Content.get_answer!(answer.id)
    end

    test "delete_answer/1 deletes the answer" do
      answer = answer_fixture()
      assert {:ok, %Answer{}} = Content.delete_answer(answer)
      assert_raise Ecto.NoResultsError, fn -> Content.get_answer!(answer.id) end
    end

    test "change_answer/1 returns a answer changeset" do
      answer = answer_fixture()
      assert %Ecto.Changeset{} = Content.change_answer(answer)
    end
  end
end
