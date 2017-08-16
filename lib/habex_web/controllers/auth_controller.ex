defmodule HabexWeb.AuthController do
  use HabexWeb, :controller

  alias Comeonin.Bcrypt
  alias Habex.{Repo, User}

  def signup(conn, %{"email" => email, "password" => password, "password_confirm" => password_confirm}) do
    if password != password_confirm do
      conn
      |> put_status(:bad_request)
      |> json(%{message: "Passwords do not match."})
    end

    password_hash = Bcrypt.hashpwsalt(password)

    case Repo.insert(User.changeset(%User{}, %{email: email, password_hash: password_hash})) do
      {:ok, %User{"id": id, "email": email}} ->
        {:ok, token, _map} = Guardian.encode_and_sign(%User{id: id})
        conn
        |> put_status(:created)
        |> json(%{id: id, email: email, token: token})
      {:error, _changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{message: "Email has been registered already."})
    end
  end
end
