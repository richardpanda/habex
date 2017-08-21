defmodule HabexWeb.TaskController do
  use HabexWeb, :controller

  alias Habex.{Repo, Status, Task}

  import Ecto.Query, only: [from: 2]

  plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__

  def create(conn, %{"name" => name}) do
    user = Guardian.Plug.current_resource(conn)

    changeset = %Task{
      name: name,
      user_id: user.id,
      statuses: [
        %Status{
          date: Date.utc_today()
        }
      ]
    }

    case Repo.insert(changeset) do
      {:ok, task} -> 
        conn
        |> put_status(:created)
        |> json(%{id: task.id, name: task.name})
      {:error, changeset} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: changeset.errors})
    end
  end

  def get_tasks_by_date(conn, %{"date" => date}) do
    user = Guardian.Plug.current_resource(conn)

    query = from t in Task,
              join: s in assoc(t, :statuses),
              where: t.user_id == ^user.id,
              where: t.id == s.task_id,
              where: s.date == ^date,
              order_by: t.inserted_at,
              preload: [statuses: s]
    
    tasks = 
      Repo.all(query)
      |> Enum.map(fn t ->
                    status = List.first(t.statuses)
                    %{id: t.id, name: t.name, status_id: status.id, date: status.date, done: status.done}
                  end)

    conn
    |> put_status(:ok)
    |> json(%{tasks: tasks})
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(401)
    |> json(%{message: "Authentication is required."})
  end
end
