defmodule Cerberus.ViewHelpersTest do
  use ExUnit.Case
  doctest Cerberus.ViewHelpers

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

      #Scopes
      ##Admin
      def scope(%User{admin: true} = _user, _scope, _action), do: :admin_scope

      ##Non-Admin
      def scope(_user, _scope, _action), do: :non_admin_scope
    end
  end

  defmodule PuppyView do
    import Cerberus.ViewHelpers

    def able_to_view_puppies_index_link?(user) do
      sanctioned?(user, :index, Puppy)
    end

    def able_to_view_puppy_show_link?(user, puppy) do
      sanctioned?(user, :show, puppy)
    end
  end

  alias Cerberus.ViewHelpersTest.PuppyView
  alias Cerberus.ViewHelpersTest.Puppy
  alias Cerberus.ViewHelpersTest.User

  test "returns correct boolean value for user auth privileges for a resource" do
    admin = %User{id: 1, admin: true}
    non_admin = %User{id: 2}

    admin_puppy = %Puppy{user_id: admin.id}
    non_admin_puppy = %Puppy{user_id: non_admin.id}

    #admin
    assert PuppyView.able_to_view_puppies_index_link?(admin)
    assert PuppyView.able_to_view_puppy_show_link?(admin, admin_puppy)
    assert PuppyView.able_to_view_puppy_show_link?(admin, non_admin_puppy)

    #non-admin
    assert PuppyView.able_to_view_puppies_index_link?(non_admin)
    refute PuppyView.able_to_view_puppy_show_link?(non_admin, admin_puppy)
    assert PuppyView.able_to_view_puppy_show_link?(non_admin, non_admin_puppy)
  end
end
