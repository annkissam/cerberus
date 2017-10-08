defmodule Cerberus do
  @moduledoc """
  Lightweight, flexible resource authorization (similar to the Ruby gem Pundit)
  """

  @spec sanctioned?(user :: any, action :: atom, resource :: any) :: boolean
  def sanctioned?(user, action, resource) do
    resource
    |> fetch_policy_module
    |> apply(:sanction, [user, action, resource])
  end

  @spec sanctioned?(user :: any, action :: atom, resource :: any) :: boolean
  def sanctioned?(mod, user, action, resource) do
    apply(mod, :sanction, [user, action, resource])
  end

  @spec auth_scope(user :: any, scope :: any, action :: atom) :: any
  def auth_scope(user, scope, action) do
    scope
    |> fetch_policy_module
    |> apply(:scope, [user, scope, action])
  end

  @spec auth_scope(user :: any, scope :: any, action :: atom) :: any
  def auth_scope(mod, user, scope, action) do
    apply(mod, :scope, [user, scope, action])
  end

  @spec fetch_policy_module(any) :: module | :error
  def fetch_policy_module(arg), do: Cerberus.PolicyFinder.call(arg)
end
