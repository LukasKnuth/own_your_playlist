defmodule OwnYourPlaylist.Streamer.Spotify.TokenJob do
  @moduledoc """
  A simple Job to fetch an initial Spotify Token using Client ID/Secret and
  then periodically renew said token.
  """
  use GenServer, restart: :transient

  require Logger
  alias OwnYourPlaylist.Streamer.Spotify.Account

  # PUBLIC
  def start_link(opts) do
    opts = Keyword.put(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, [], opts)
  end
  
  def token do
    GenServer.call(__MODULE__, :get_token)
  end

  # PRIVATE
  @impl true
  def init(_opts) do
    case refresh_token() do
      {:ok, token, expires_seconds} ->
        reschedule(expires_seconds)
        {:ok, token}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_info(:refresh, _old_token) do
    case refresh_token() do
      {:ok, token, expires_seconds} ->
        reschedule(expires_seconds)
        {:norply, token}

      {:error, reason} ->
        {:stop, reason, nil}
    end
  end

  @impl true
  def handle_info(_msg, state), do: {:noreply, state}

  @impl true
  def handle_call(:get_token, _from, current_token), do: {:reply, current_token, current_token}

  defp refresh_token do
    Logger.info("Getting new Access Token from Spotify")
    Account.auth_token()
  end

  defp reschedule(expiry_in_seconds) do
    # The expected delay returned by Spotify API is one hour (3600 seconds)
    delay = :timer.seconds(expiry_in_seconds) - :timer.minutes(5)
    Process.send_after(self(), :refresh, delay)
    :ok
  end
end
