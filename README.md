# Cerberus

Lightweight, flexible resource authorization (similar to the Ruby gem Pundit)

Due to its flexibility, `cerberus` can be used with both Phoenix 1.2 and 1.3 as it doesn't depend on phoenix


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `cerberus` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:cerberus, "~> 0.2.0"}]
    end
    ```

  2. Ensure `cerberus` is started before your application:

    ```elixir
    def application do
      [applications: [:cerberus]]
    end
    ```

