defmodule Cerberus.AuthorizationFailedError do
  @moduledoc """
  Raised when authorization of a resource fails.
  """
  defexception [conn: nil, message: "Not Authorized"]
end

defmodule Cerberus.AuthorizationNotPerformedError do
  @moduledoc """
  Raised when authorization has not been implemented by the end of the Plug
  pipeline.
  """
  defexception [conn: nil, message: "Not Authorized"]
end

defimpl Plug.Exception, for: Cerberus.AuthorizationFailedError do
  def status(_exception), do: 403
end

defimpl Plug.Exception, for: Cerberus.AuthorizationNotPerformedError do
  def status(_exception), do: 403
end
