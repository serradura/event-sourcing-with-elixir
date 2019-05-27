use Mix.Config

# Configure your database
config :bank_api, BankAPI.Repo,
  username: "serradura",
  password: "",
  database: "bank_api_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bank_api, BankAPIWeb.Endpoint,
  http: [port: 4002],
  server: false

# Configure Commanded event store
config :commanded,
  event_store_adapter: Commanded.EventStore.Adapters.InMemory

config :commanded, Commanded.EventStore.Adapters.InMemory,
  serializer: Commanded.Serialization.JsonSerializer

# Print only warnings and errors during test
config :logger, level: :warn
