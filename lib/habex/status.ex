defmodule Habex.Status do
  use Ecto.Schema
  import Ecto.Changeset
  alias Habex.{Status, Task}


  schema "statuses" do
    field :date, :date
    field :done, :boolean, default: false
    belongs_to :task, Task

    timestamps()
  end

  @doc false
  def changeset(%Status{} = status, attrs) do
    status
    |> cast(attrs, [:date, :done, :task_id])
    |> validate_required([:date, :done, :task_id])
    |> assoc_constraint(:task)
  end
end
