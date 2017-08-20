defmodule HabexWeb.AuthEndpointTest do
  use HabexWeb.ConnCase

  alias Habex.{Repo, User}

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
