defmodule Answerwrong.Repo.Migrations.AddUserToAnswer do
  use Ecto.Migration

  def change do
    alter table(:answers) do
      add :user_id, references(:users)
    end
  end
end
