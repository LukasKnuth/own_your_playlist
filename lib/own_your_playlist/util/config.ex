defmodule OwnYourPlaylist.Util.Config do
  @moduledoc """
  Simple helpers to interact with Application configuration.
  """

  @otp_app :own_your_playlist

  @doc """
  Read the configuration value for the given Module and key from
  Application config at runtime.
  """
  def read!(mod, key) do
    @otp_app
    |> Application.fetch_env!(mod)
    |> Keyword.fetch!(key)
  end
end
