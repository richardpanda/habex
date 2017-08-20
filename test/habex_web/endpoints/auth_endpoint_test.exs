defmodule HabexWeb.AuthEndpointTest do
  use HabexWeb.ConnCase

  alias Comeonin.Bcrypt
  alias Habex.{Repo, User}

  describe "POST /auth/signin" do
    test "Send 200 for valid credentials" do
      password = "password"
      password_hash = Bcrypt.hashpwsalt(password)
      User.changeset(%User{}, %{email: "test@test.com", password_hash: password_hash})
      |> Repo.insert()

      req_body = [email: "test@test.com", password: password]
      conn = post build_conn(), "/auth/signin", req_body
      resp_body = Poison.decode! conn.resp_body

      assert conn.status == 200
      assert resp_body["email"] == "test@test.com"
      assert resp_body["id"]
      assert resp_body["token"]
    end

    test "Send 400 for unregistered email" do
      req_body = [email: "test@test.com", password: "password"]
      conn = post build_conn(), "/auth/signin", req_body
      resp_body = Poison.decode! conn.resp_body

      assert conn.status == 400
      assert resp_body["message"] == "Invalid email and/or password."
    end

    test "Send 400 for invalid password" do
      password = "password"
      password_hash = Bcrypt.hashpwsalt(password)
      User.changeset(%User{}, %{email: "test@test.com", password_hash: password_hash})
      |> Repo.insert()

      req_body = [email: "test@test.com", password: "123456"]
      conn = post build_conn(), "/auth/signin", req_body
      resp_body = Poison.decode! conn.resp_body

      assert conn.status == 400
      assert resp_body["message"] == "Invalid email and/or password."
    end
  end

  describe "POST /auth/signup" do
    test "Creates and responds with a newly created user if attributes are valid" do
      req_body = [email: "test@test.com", password: "password", password_confirm: "password"]
      conn = post build_conn(), "/auth/signup", req_body
      resp_body = Poison.decode! conn.resp_body

      assert conn.status == 201
      assert resp_body["email"]
      assert resp_body["id"]
      assert resp_body["token"]
    end

    test "Return an error if password and password_confirm do not match" do
      req_body = [email: "test@test.com", password: "password", password_confirm: "123456"]
      conn = post build_conn(), "/auth/signup", req_body
      resp_body = Poison.decode! conn.resp_body

      assert conn.status == 400
      assert resp_body["message"] == "Passwords do not match."
    end

    test "Return an error if email has been registered already" do
      req_body = [email: "test@test.com", password: "password", password_confirm: "password"]

      User.changeset(%User{}, %{email: "test@test.com", password_hash: "password"})
      |> Repo.insert()

      conn = post build_conn(), "/auth/signup", req_body
      resp_body = Poison.decode! conn.resp_body

      assert conn.status == 400
      assert resp_body["message"] == "Email has been registered already."
    end
  end
end
