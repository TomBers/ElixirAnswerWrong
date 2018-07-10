defmodule Answerwrong.Repo.Migrations.CreateAnswers do
  use Ecto.Migration

  def change do
    create table(:answers) do
      add :text, :string
      add :display_count, :integer
      add :score, :integer

      timestamps()
    end

  end
end
