defmodule HabexWeb.ApiEndpointTest do
  use HabexWeb.ConnCase

  alias Habex.{Repo, Status, Task, User}

  describe "POST /api/tasks" do
    test "create task given token and name" do
      user =
        User.changeset(%User{}, %{email: "test@test.com", password_hash: "password"})
        |> Repo.insert!()

      {:ok, token, _map} = Guardian.encode_and_sign(%User{id: user.id})

      req_body = [name: "Exercise"]
      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{token}")
        |> post("/api/tasks", req_body)
      resp_body = Poison.decode!(conn.resp_body)

      task =
        Task
        |> Repo.all()
        |> List.first()
      
      status =
        Status
        |> Repo.all()
        |> List.first()

      assert conn.status == 201
      assert resp_body["name"] == "Exercise"
      assert resp_body["id"]

      assert task.name == "Exercise"
      assert task.user_id == user.id

      assert status.date == Date.utc_today()
      assert status.task_id == task.id
      refute status.done
    end

    test "cannot create task without a token" do
      req_body = [name: "Exercise"]
      conn =
        build_conn()
        |> post("/api/tasks", req_body)
      resp_body = Poison.decode!(conn.resp_body)

      assert conn.status == 401
      assert resp_body["message"] == "Authentication is required."
    end
  end
end
