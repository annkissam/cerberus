defmodule Cerberus.PolicyFinder do
  @moduledoc """
  Finds policy module for corresponding data structure.  Policies are found via
  the following naming convention:

  The policy for a given resource should be named by appending "Policy" to the
  module name of the resource.

  E.g.) for resource `X`, the corresponding policy would be defined as
  `X.Policy`
  """

  @doc """
  Finds the policy module based off of the data structure of the provided
  argument. If a corresponding policy is not found, `:error` is returned.

  ## Examples

    - when Puppy.Policy is defined

      ```
      Cerberus.PolicyFinder.call(Puppy)    #=> Puppy.Policy

      Cerberus.PolicyFinder.call(%Puppy{}) #=> Puppy.Policy
      ```

    - when a policy is **not** defined for a structure

      ```
      Cerberus.PolicyFinder.call(Kitten{})  #=> :error

      Cerberus.PolicyFinder.call(%Kitten{}) #=> :error

      Cerberus.PolicyFinder.call(nil)       #=> :error
      ```
  """
  @spec call(any) :: module | :error
  def call(arg), do: policy_module(arg)

  defp policy_module(nil), do: :error
  defp policy_module(%{from: {source, schema}})
    when is_binary(source) and is_atom(schema), do: policy_module(schema)
  defp policy_module(%{__struct__: module}), do: policy_module(module)
  defp policy_module(module) when is_atom(module) do
    try do
      Module.safe_concat(module, "Policy")
    rescue
      ArgumentError -> :error
    end
  end
  defp policy_module(_), do: :error
end
