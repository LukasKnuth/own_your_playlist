defmodule OwnYourPlaylist.Finch do
	@moduledoc """
  A central place to put configuration for the global Finch HTTP client and
  add specific behaviour changes. The client is registered under this modules
  `__MODULE__`, so it makes it easier to referr to it.
  """

  @doc false
  def child_spec(opts) do
    Finch.child_spec(custom_options(opts))
  end

  defp custom_options(_opts) do
    [name: __MODULE__]
  end
end
