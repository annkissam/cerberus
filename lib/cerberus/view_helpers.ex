defmodule Cerberus.ViewHelpers do
  @moduledoc """
  Module that contains helper methods to be used in views & templates
  """

  @doc """
  Just an ease-of-access method that delegates to Cerberus.sanctioned?/3
  """
  @spec sanctioned?(
    user :: any,
    action :: atom,
    resource :: any
  ) :: boolean
  def sanctioned?(user, action, resource), do: Cerberus.sanctioned?(user, action, resource)
end

