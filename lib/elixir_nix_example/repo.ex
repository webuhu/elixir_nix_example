defmodule ElixirNixExample.Repo do
  use Ecto.Repo,
    otp_app: :elixir_nix_example,
    adapter: Ecto.Adapters.Postgres
end
