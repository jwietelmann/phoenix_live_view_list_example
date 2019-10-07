defmodule LiveViewLists.Repo do
  use Ecto.Repo,
    otp_app: :live_view_lists,
    adapter: Ecto.Adapters.Postgres
end
