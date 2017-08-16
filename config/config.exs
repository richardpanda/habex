# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :habex,
  ecto_repos: [Habex.Repo]

# Configures the endpoint
config :habex, HabexWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "MfTgOeBeQsFNW6YZsFh1h/lxkXo157+GBUIyKVtdLKv9HC4muwhaooHsASFpQ3ij",
  render_errors: [view: HabexWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Habex.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  issuer: "Habex",
  ttl: { 30, :days},
  serializer: Habex.GuardianSerializer,
  secret_key: System.get_env("HABEX_JWT_SECRET")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
