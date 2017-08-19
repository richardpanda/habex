defmodule Habex.Task do
  use Ecto.Schema
  import Ecto.Changeset
  alias Habex.{Status, Task, User}


  schema "tasks" do
    field :name, :string
    belongs_to :user, User
    has_many :statuses, Status

    timestamps()
  end

  @doc false
  def changeset(%Task{} = task, attrs) do
    task
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
    |> assoc_constraint(:user)
  end
end
