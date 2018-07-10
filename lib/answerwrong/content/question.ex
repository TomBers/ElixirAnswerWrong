defmodule Answerwrong.Content.Question do
  use Ecto.Schema
  import Ecto.Changeset


  schema "questions" do
    field :answer, :string
    field :display_count, :integer, default: 0
    field :question, :string
    timestamps()
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:question, :answer, :display_count])
    |> validate_required([:question, :answer, :display_count])
  end
end
