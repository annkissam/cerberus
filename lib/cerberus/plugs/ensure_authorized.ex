defmodule Cerberus.Plugs.EnsureAuthorized do
  # TODO: Consistency with Cereberus and Phoenix
  #
  def init(params) do
    params
  end

  def call(conn, opts) do
    handler = Keyword.get(opts, :handler)
    user = Keyword.get(opts, :usrfn).(conn)

    authorize(handler, conn, user)
  end

  defp authorize(handler, conn, user) do
    # Need phoenix for this
    action = conn[:action]

    resource = nil
    # resource = Policy.get_resource(conn, action)

    Cerberus.sanctioned?(handler, user, resource, action)
  end
end
