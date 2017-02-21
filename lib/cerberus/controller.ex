defmodule Cerberus.Controller do
  @moduledoc """
  Wraps controllers with Cerberus authorization methods.
  """

  @doc """
  Authorizes a resource, for a user, for a given action, then marks the connection as having had cerberus_auth_perfomed
  """
  @spec authorize(
    conn :: Plug.Conn.t,
    user :: any,
    resource :: any,
    action :: atom
  ) :: Plug.Conn.t
  def authorize(conn, user, resource, action) do
    conn
    |> perform_auth(user, resource, action)
    |> Plug.Conn.put_private(:cerberus_auth_performed, true)
  end

  @spec perform_auth(
    conn :: Plug.Conn.t,
    user :: any,
    resource :: any,
    action :: atom
  ) :: Plug.Conn.t
  defp perform_auth(conn, user, resource, action) do
    if Cerberus.sanctioned?(user, action, resource) do
      conn
    else
      raise Cerberus.AuthorizationFailedError, conn: conn
    end
  end

  @doc """
  Applies authorization scope for a resource, for a user.
  """
  @spec auth_scope(
    user :: any,
    scope :: any,
    action :: atom
  ) :: any
  def auth_scope(user, scope, action), do: Cerberus.auth_scope(user, scope, action)
end
