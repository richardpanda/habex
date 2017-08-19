defmodule Habex.Repo.Migrations.CreateStatuses do
  use Ecto.Migration

  def change do
    create table(:statuses) do
      add :date, :date
      add :done, :boolean, default: false, null: false
      add :task_id, references(:tasks, on_delete: :delete_all)

      timestamps()
    end

    create index(:statuses, [:task_id])
  end
end
