defmodule EpubApi.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: EpubApi,
        options: Application.get_env(:epub_api, :endpoint)[:port]
      ),
    ]

    opts = [strategy: :one_for_one, name: EpubApi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
