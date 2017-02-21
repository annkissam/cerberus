defmodule CerberusTest do
  use ExUnit.Case
  doctest Cerberus

  defmodule User do
    defstruct [id: nil, admin: false]
  end

  defmodule Puppy do
    defstruct [id: nil, user_id: nil, fed: false]

    defmodule Policy do
      @behaviour Cerberus.Policy

      #Sanctions
      ##Admin
      def sanction(%User{admin: true}, _action, _puppy), do: true

      ##Non-Admin
      ###index
      def sanction(_user, :index, _puppy), do: true

      ###show
      def sanction(%User{id: id}, :show, %Puppy{user_id: user_id}) when id == user_id, do: true
      def sanction(_user, :show, _puppy), do: false

      ###new/create
      def sanction(_user, :new, _puppy), do: true
      def sanction(user, :create, puppy), do: sanction(user, :new, puppy)

      ###edit/update
      def sanction(%User{id: id}, :edit, %Puppy{user_id: user_id}) when id == user_id, do: true
      def sanction(_user, :edit, _puppy), do: false
      def sanction(user, :update, puppy), do: sanction(user, :edit, puppy)

      ###delete
      def sanction(%User{id: id}, :delete, %Puppy{user_id: user_id}) when id == user_id, do: true
      def sanction(_user, :delete, _puppy), do: false

      ###feed_treats (custom action)
      def sanction(%User{id: id}, :feed_treats, %Puppy{user_id: user_id}) when id == user_id, do: true
      def sanction(_user, :feed_treats, _puppy), do: false

      #Scopes
      ##Admin
      def scope(%User{admin: true} = _user, _scope, _action), do: :admin_scope

      ##Non-Admin
      def scope(_user, _scope, _action), do: :non_admin_scope
    end
  end

  alias CerberusTest.Puppy
  alias CerberusTest.User

  describe "Cerberus.sanctioned?/3" do
    test "correctly sanctions resources via policy" do
      admin = %User{id: 1, admin: true}
      non_admin = %User{id: 2}

      admin_puppy = %Puppy{user_id: admin.id}
      non_admin_puppy = %Puppy{user_id: non_admin.id}
      other_puppy = %Puppy{}

      #admin
      assert Cerberus.sanctioned?(admin, :index, Puppy)
      assert Cerberus.sanctioned?(admin, :show, admin_puppy)
      assert Cerberus.sanctioned?(admin, :show, non_admin_puppy)
      assert Cerberus.sanctioned?(admin, :show, other_puppy)
      assert Cerberus.sanctioned?(admin, :new, Puppy)
      assert Cerberus.sanctioned?(admin, :create, Puppy)
      assert Cerberus.sanctioned?(admin, :edit, admin_puppy)
      assert Cerberus.sanctioned?(admin, :edit, non_admin_puppy)
      assert Cerberus.sanctioned?(admin, :edit, other_puppy)
      assert Cerberus.sanctioned?(admin, :update, admin_puppy)
      assert Cerberus.sanctioned?(admin, :update, non_admin_puppy)
      assert Cerberus.sanctioned?(admin, :update, other_puppy)
      assert Cerberus.sanctioned?(admin, :delete, admin_puppy)
      assert Cerberus.sanctioned?(admin, :delete, non_admin_puppy)
      assert Cerberus.sanctioned?(admin, :delete, other_puppy)

      #non-admin
      assert Cerberus.sanctioned?(non_admin, :index, Puppy)
      refute Cerberus.sanctioned?(non_admin, :show, admin_puppy)
      assert Cerberus.sanctioned?(non_admin, :show, non_admin_puppy)
      refute Cerberus.sanctioned?(non_admin, :show, other_puppy)
      assert Cerberus.sanctioned?(non_admin, :new, Puppy)
      assert Cerberus.sanctioned?(non_admin, :create, Puppy)
      refute Cerberus.sanctioned?(non_admin, :edit, admin_puppy)
      assert Cerberus.sanctioned?(non_admin, :edit, non_admin_puppy)
      refute Cerberus.sanctioned?(non_admin, :edit, other_puppy)
      refute Cerberus.sanctioned?(non_admin, :update, admin_puppy)
      assert Cerberus.sanctioned?(non_admin, :update, non_admin_puppy)
      refute Cerberus.sanctioned?(non_admin, :update, other_puppy)
      refute Cerberus.sanctioned?(non_admin, :delete, admin_puppy)
      assert Cerberus.sanctioned?(non_admin, :delete, non_admin_puppy)
      refute Cerberus.sanctioned?(non_admin, :delete, other_puppy)
    end
  end

  describe "Cerberus.auth_scope/3" do
    test "correctly scopes resources via policy" do
      admin = %User{admin: true}
      non_admin = %User{}
      mock_ecto_scope = %{from: {"puppies", Puppy}}

      assert Cerberus.auth_scope(admin, mock_ecto_scope, :index) == :admin_scope
      assert Cerberus.auth_scope(non_admin, mock_ecto_scope, :index) == :non_admin_scope
    end
  end


  describe "controller integration" do
    defmodule PuppyController do
      import Cerberus.Controller

      defp result_tup(conn, val) do
        {conn.private[:cerberus_auth_performed], val}
      end

      def index(conn, _params, user) do
        conn = authorize(conn, user, Puppy, :index)
        puppies = auth_scope(user, Puppy, :index)

        result_tup(conn, puppies)
      end

      def show(conn, %{"puppy" => puppy}, user) do
        conn
        |> authorize(user, puppy, :show)
        |> result_tup(puppy)
      end

      def new(conn, _params, user) do
        conn
        |> authorize(user, Puppy, :new)
        |> result_tup(Puppy)
      end

      def create(conn, %{"puppy" => puppy}, user) do
        conn
        |> authorize(user, Puppy, :create)
        |> result_tup(puppy)
      end

      def edit(conn, %{"puppy" => puppy}, user) do
        conn
        |> authorize(user, puppy, :edit)
        |> result_tup(puppy)
      end

      def update(conn, %{"puppy" => puppy}, user) do
        conn
        |> authorize(user, puppy, :update)
        |> result_tup(puppy)
      end

      def delete(conn, %{"puppy" => puppy}, user) do
        conn
        |> authorize(user, puppy, :delete)
        |> result_tup(nil)
      end

      def feed_treats(conn, %{"puppy" => puppy}, user) do
        conn
        |> authorize(user, puppy, :feed_treats)
        |> result_tup(%{puppy | fed: true})
      end
    end

    alias CerberusTest.PuppyController

    test "correctly authorizes & scopes resources, and marks conn as having been authorized" do
      admin = %User{id: 1, admin: true}
      non_admin = %User{id: 2}
      admin_puppy = %Puppy{user_id: admin.id}
      non_admin_puppy = %Puppy{user_id: non_admin.id}

      admin_params = %{"puppy" => admin_puppy}
      non_admin_params = %{"puppy" => non_admin_puppy}

      #index
      assert PuppyController.index(%Plug.Conn{}, admin_params, admin) == {true, :admin_scope}
      assert PuppyController.index(%Plug.Conn{}, non_admin_params, non_admin) == {true, :non_admin_scope}

      #show
      ##success
      assert PuppyController.show(%Plug.Conn{}, admin_params, admin) == {true, admin_puppy}
      assert PuppyController.show(%Plug.Conn{}, non_admin_params, admin) == {true, non_admin_puppy}
      assert PuppyController.show(%Plug.Conn{}, non_admin_params, non_admin) == {true, non_admin_puppy}
      ##failure
      assert_raise Cerberus.AuthorizationFailedError, fn -> PuppyController.show(%Plug.Conn{}, admin_params, non_admin) end

      #new
      assert PuppyController.new(%Plug.Conn{}, admin_params, admin) == {true, Puppy}
      assert PuppyController.new(%Plug.Conn{}, non_admin_params, non_admin) == {true, Puppy}

      #create
      assert PuppyController.create(%Plug.Conn{}, admin_params, admin) == {true, admin_puppy}
      assert PuppyController.create(%Plug.Conn{}, non_admin_params, non_admin) == {true, non_admin_puppy}

      #edit
      ##success
      assert PuppyController.edit(%Plug.Conn{}, admin_params, admin) == {true, admin_puppy}
      assert PuppyController.edit(%Plug.Conn{}, non_admin_params, admin) == {true, non_admin_puppy}
      assert PuppyController.edit(%Plug.Conn{}, non_admin_params, non_admin) == {true, non_admin_puppy}
      ##failure
      assert_raise Cerberus.AuthorizationFailedError, fn -> PuppyController.edit(%Plug.Conn{}, admin_params, non_admin) end

      #update
      ##success
      assert PuppyController.update(%Plug.Conn{}, admin_params, admin) == {true, admin_puppy}
      assert PuppyController.update(%Plug.Conn{}, non_admin_params, admin) == {true, non_admin_puppy}
      assert PuppyController.update(%Plug.Conn{}, non_admin_params, non_admin) == {true, non_admin_puppy}
      ##failure
      assert_raise Cerberus.AuthorizationFailedError, fn -> PuppyController.edit(%Plug.Conn{}, admin_params, non_admin) end

      #delete
      ##success
      assert PuppyController.delete(%Plug.Conn{}, admin_params, admin) == {true, nil}
      assert PuppyController.delete(%Plug.Conn{}, non_admin_params, admin) == {true, nil}
      assert PuppyController.delete(%Plug.Conn{}, non_admin_params, non_admin) == {true, nil}
      ##failure
      assert_raise Cerberus.AuthorizationFailedError, fn -> PuppyController.delete(%Plug.Conn{}, admin_params, non_admin) end

      #feed_treats (custom action)

      fed_admin_puppy = %{admin_puppy | fed: true}
      fed_non_admin_puppy = %{non_admin_puppy | fed: true}

      ##success
      assert PuppyController.feed_treats(%Plug.Conn{}, admin_params, admin) == {true, fed_admin_puppy}
      assert PuppyController.feed_treats(%Plug.Conn{}, non_admin_params, admin) == {true, fed_non_admin_puppy}
      assert PuppyController.feed_treats(%Plug.Conn{}, non_admin_params, non_admin) == {true, fed_non_admin_puppy}
      ##failure
      assert_raise Cerberus.AuthorizationFailedError, fn -> PuppyController.feed_treats(%Plug.Conn{}, admin_params, non_admin) end
    end
  end
end

