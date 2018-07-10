defmodule Answerwrong.Content.Answer do
  use Ecto.Schema
  import Ecto.Changeset


  schema "answers" do
    field :display_count, :integer, default: 0
    field :score, :integer, default: 0
    field :text, :string
    belongs_to :question, Question

    timestamps()
  end

  @doc false
  def changeset(answer, attrs) do
    answer
    |> cast(attrs, [:text, :display_count, :score, :question_id])
    |> foreign_key_constraint(:question_id)
    |> validate_required([:text, :question_id])
  end
end
