defmodule HabexWeb.AuthController do
  use HabexWeb, :controller

  alias Comeonin.Bcrypt
  alias Habex.{Repo, User}

  def signin(conn, %{"email" => email, "password" => password}) do
    case Repo.get_by(User, email: email) do
      nil ->
        conn
        |> put_status(:bad_request)
        |> json(%{message: "Invalid email and/or password."})
      user ->
        case Bcrypt.checkpw(password, user.password_hash) do
          true ->
            {:ok, token, _map} = Guardian.encode_and_sign(%User{id: user.id})
            conn
            |> put_status(:ok)
            |> json(%{id: user.id, email: email, token: token})
          false ->
            conn
            |> put_status(:bad_request)
            |> json(%{message: "Invalid email and/or password."})
        end
    end
  end

  def signup(conn, %{"email" => email, "password" => password, "password_confirm" => password_confirm}) do
    case password == password_confirm do
      true ->
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
      false ->
        conn
        |> put_status(:bad_request)
        |> json(%{message: "Passwords do not match."}) 
    end
  end
end
