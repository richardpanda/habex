defmodule HabexWeb.Router do
  use HabexWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  scope "/", HabexWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", HabexWeb do
    pipe_through :api

    post "/tasks", TaskController, :create
  end

  scope "/auth", HabexWeb do
    post "/signin", AuthController, :signin
    post "/signup", AuthController, :signup
  end

  # Other scopes may use custom stacks.
  # scope "/api", HabexWeb do
  #   pipe_through :api
  # end
end
