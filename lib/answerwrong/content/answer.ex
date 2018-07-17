defmodule Answerwrong.Content.Answer do
  use Ecto.Schema
  import Ecto.Changeset


  schema "answers" do
    field :display_count, :integer, default: 0
    field :score, :integer, default: 0
    field :text, :string
    belongs_to :question, Question
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(answer, attrs) do
    answer
    |> cast(attrs, [:text, :display_count, :score, :question_id, :user_id])
    |> foreign_key_constraint(:question_id)
    |> foreign_key_constraint(:user_id)
    |> validate_required([:text, :question_id, :user_id])
  end
end
