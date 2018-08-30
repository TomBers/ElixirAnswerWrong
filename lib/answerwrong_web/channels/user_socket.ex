defmodule AnswerwrongWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "room:*", AnswerwrongWeb.RoomChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  @max_age 24 * 60 * 60 * 100
  def connect(%{"token" => token}, socket) do
    case Phoenix.Token.verify(socket, "user token", token, max_age: @max_age) do
      {:ok, user_id} ->
        {:ok, assign(socket, :current_user_id, user_id)}
      {:error, _reason} ->
        :error
    end
  end

  def id(_socket), do: nil
end
