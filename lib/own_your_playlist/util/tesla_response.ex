defmodule OwnYourPlaylist.Util.TeslaResponse do
  @moduledoc """
  Simple helper to convert a `Tesla.Env` into a usable success/error result.
  """
  require Logger
  alias Tesla.Env

  @type body :: binary()
  @type status :: pos_integer()
  @type reason :: any()

  @doc """
  Handles the response from a `Tesla` request in the following way:
  """
  @spec handle_response(tuple()) :: {:ok, body()} | {:error, {:status, status()}} | {:error, reason()}
  def handle_response({:ok, %Env{status: status, body: body}}) when status >= 200 and status < 300 do
    {:ok, body}
  end

  def handle_response({:ok, %Env{status: status, body: body}}) do
    Logger.error("Service response indicates error", status: status, body: body)
    
    {:error, {:status, status}}
  end

  def handle_response({:error, _} = err) do
    Logger.error("Unhandled error in client", error: err)

    err
  end
end
