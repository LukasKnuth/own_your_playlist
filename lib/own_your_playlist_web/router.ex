defmodule OwnYourPlaylistWeb.Router do
  use OwnYourPlaylistWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {OwnYourPlaylistWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", OwnYourPlaylistWeb do
    pipe_through :browser

    live_session :default do
      live "/", Live.Landing
    end
  end
end
