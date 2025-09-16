defmodule RiddlerAdmin.Schema do
  @moduledoc """
  Base schema module for RiddlerAdmin schemas with automatic type generation.

  Provides common schema configuration including UXID-based primary keys,
  foreign key types, timestamp options, and automatic typespec generation.
  All schemas should use this module for consistent ID generation and type safety.
  """

  defmacro __using__(opts \\ []) do
    quote do
      prefix = Keyword.fetch!(unquote(opts), :prefix)
      rand_size = Keyword.get(unquote(opts), :rand_size)
      size = Keyword.get(unquote(opts), :size, :xlarge)

      use TypedEctoSchema

      @primary_key {:id, UXID,
                    autogenerate: true, prefix: prefix, size: size, rand_size: rand_size}
      @foreign_key_type :string
      @timestamps_opts [type: :utc_datetime_usec]
    end
  end
end
