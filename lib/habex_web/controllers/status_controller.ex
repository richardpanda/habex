defmodule HabexWeb.StatusController do
  use HabexWeb, :controller

  alias Habex.{Repo, Status, Task}

  import Ecto.Query, only: [from: 2]

  plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__

  def update(conn, %{"done" => done, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    query = from t in Task,
              join: s in assoc(t, :statuses),
              where: t.user_id == ^user.id,
              where: s.id == ^id,
              preload: [statuses: s]
    
    num_results =
      Repo.all(query)
      |> length

    case num_results do
      0 ->
        conn
        |> put_status(:unauthorized)
        |> json(%{message: "You do not have permission to do that."})
      _ ->
        status =
          Repo.get(Status, id)
          |> Ecto.Changeset.change(done: done)

        case Repo.update(status) do
          {:ok, status} ->
            conn
            |> put_status(:ok)
            |> json(%{date: status.date, done: status.done, id: status.id})
          {:error, changeset} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: changeset.errors})
        end
    end
  end
end
