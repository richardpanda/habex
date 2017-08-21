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

  describe "GET /api/tasks/:date" do
    test "get all tasks for a given date" do
      today = Date.utc_today()
      yesterday = Date.add(today, -1)

      user =
        User.changeset(%User{}, %{email: "test@test.com", password_hash: "password"})
        |> Repo.insert!()

      Repo.insert(%Task{
        name: "Task 1",
        user_id: user.id,
        statuses: [
          %Status{date: today},
          %Status{date: yesterday}
        ]
      })
      Repo.insert(%Task{
        name: "Task 2",
        user_id: user.id,
        statuses: [
          %Status{date: today}
        ]
      })

      {:ok, token, _map} = Guardian.encode_and_sign(%User{id: user.id})

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{token}")
        |> get("/api/tasks/#{today}")
      %{"tasks" => tasks} = Poison.decode!(conn.resp_body)

      assert conn.status == 200
      assert length(tasks) == 2
      assert Enum.at(tasks, 0)["name"] == "Task 1"
      assert Enum.at(tasks, 1)["name"] == "Task 2"
    end

    test "cannot get tasks without a token" do
      conn =
        build_conn()
        |> get("/api/tasks/#{Date.utc_today()}")
      resp_body = Poison.decode!(conn.resp_body)

      assert conn.status == 401
      assert resp_body["message"] == "Authentication is required."
    end
  end
end
