defmodule ChatApp.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :string
      add :timestamp, :naive_datetime
      add :pid, :string

      timestamps()
    end
  end
end