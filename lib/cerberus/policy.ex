  defmodule Cerberus.Policy do
    @moduledoc """
    Provides behavior that individual policy resources should adopt.

    ## Usage:

    ```
    defmodule SomeResource.Policy do
      @behaviour Cerberus.Policy

      def sanction(user, action, resource)
      def scope(user, scope, action)

    end
    ```
    """

    @callback sanction(user :: any, action :: atom, resource :: any) :: boolean

    @callback scope(user :: any, scope :: any, action :: atom) :: any
  end
