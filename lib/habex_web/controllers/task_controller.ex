defmodule HabexWeb.TaskController do
  use HabexWeb, :controller

  alias Habex.{Repo, Status, Task}

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

  def unauthenticated(conn, _params) do
    conn
    |> put_status(401)
    |> json(%{message: "Authentication is required."})
  end
end
