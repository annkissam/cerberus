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

  defmacro __using__(opts) do
    except = Keyword.get(opts, :except, [])
    handler = Keyword.get(opts, :handler, Cerberus.Handlers.NotAuthorized)
    policy = Keyword.get(opts, :policy, :not_given)
    usrfn = Keyword.get(opts, :usrfn, & &1.assigns[:current_user])

    quote do
      # Ideally...
      # plug Cerberus.Plug.EnsureAuthorized, [handler: unquote(handler)]
      #   when not action in unquote(except)

      def authorize(conn, user, resource, action) do
        sanctioned? = case unquote(policy) do
          :not_given -> Cerberus.sanctioned?(user, action, resource)
          mod -> Cerberus.sanctioned?(mod, user, action, resource)
        end

        case sanctioned? do
          true -> conn |> Conn.put_private(:cerberus_auth_performed, true)
          false -> apply(unquote(handler), :call, [conn])
        end
      end

      def auth_scope(user, scope, action) do
        case unquoute(policy) do
          :not_given -> Cerberus.auth_scope(user, scope, action)
          mod -> Cerberus.auth_scope(mod, user, scope, action)
        end
      end
    end
  end
end
