defmodule Cerberus.Handlers.NotAuthorized do
  import Plug.Conn

  def call(conn) do
    conn
    |> put_private(:cerberus_auth_perfomed, true)
    |> halt()
  end
end
