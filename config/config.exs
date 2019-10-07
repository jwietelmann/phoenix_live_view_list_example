# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :live_view_lists,
  ecto_repos: [LiveViewLists.Repo]

# Configures the endpoint
config :live_view_lists, LiveViewListsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "dMEBhh/PYRTx+4uSA+crMWbTZw4kzS8y8s/k+aD3JKph+3FSAde/x8BIXodAkzB2",
  render_errors: [view: LiveViewListsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LiveViewLists.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# LiveView salt
config :live_view_lists, LiveViewListsWeb.Endpoint,
  live_view: [
    signing_salt: "my very secret salt you'll never guess it"
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
