import Config

config :elixir_nix_example,
  ecto_repos: [ElixirNixExample.Repo]

# Configures the endpoint
config :elixir_nix_example, ElixirNixExampleWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "FGxG1lPDl0xzag5D/aYyTzSik7VZPNY5v39xZY7ExUZx/bipbrYRKzPV5t0CAotM",
  render_errors: [view: ElixirNixExampleWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ElixirNixExample.PubSub,
  live_view: [signing_salt: "xHz+qYRD"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
