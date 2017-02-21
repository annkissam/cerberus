defmodule Cerberus.PolicyFinderTest do
  use ExUnit.Case, async: true
  doctest Cerberus.PolicyFinder

  alias Cerberus.PolicyFinder

  defmodule Puppy do
    defstruct [id: nil]

    defmodule Policy do
    end
  end

  defmodule Kitten do
    defstruct [id: nil]
  end

  alias Cerberus.PolicyFinderTest.Puppy
  alias Cerberus.PolicyFinderTest.Kitten

  describe "Cerberus.PolicyFinder.call/1" do
    test "returns correct values" do
      # argument is a module that has a policy
      assert PolicyFinder.call(Puppy) == Puppy.Policy
      assert PolicyFinder.call(%Puppy{}) == Puppy.Policy

      # argument is a module that has a corresponding policy
      assert PolicyFinder.call(Kitten) == :error
      assert PolicyFinder.call(%Kitten{}) == :error

      # argument is an ecto query
      assert PolicyFinder.call(%{from: {"puppies", Puppy}}) == Puppy.Policy

      # argument is nil
      assert PolicyFinder.call(nil) == :error

      # argument is some other data structure
      assert PolicyFinder.call("derp") == :error
      assert PolicyFinder.call(12) == :error
    end
  end
end
