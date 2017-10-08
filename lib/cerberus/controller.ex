defmodule Cerberus.Controller do
  @moduledoc """
  Wraps controllers with Cerberus authorization methods.
  """

  alias Plug.Conn

  @doc """
  Authorizes a resource, for a user, for a given action, then marks the connection as having had cerberus_auth_perfomed
  """
  @spec authorize(
    conn :: Conn.t,
    user :: any,
    resource :: any,
    action :: atom
  ) :: Conn.t
  def authorize(conn, user, resource, action) do
    conn
    |> perform_auth(user, resource, action)
    |> Conn.put_private(:cerberus_auth_performed, true)
  end

  @spec perform_auth(
    conn :: Conn.t,
    user :: any,
    resource :: any,
    action :: atom
  ) :: Conn.t
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
  def auth_scope(user, scope, action) do
    Cerberus.auth_scope(user, scope, action)
  end
end
