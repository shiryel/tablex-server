defmodule TablexServerWeb.GameChannel do
  use TablexServerWeb, :channel
  alias TablexServerWeb.Presence
  alias TablexServer.Game

  def join("game:" <> _room, _params, socket) do
    send(self(), :after_join)
    game = Game.new()
    socket = assign(socket, :game, game)
    {:ok, game, socket}
  end

  def join(_, _, _) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info(:after_join, socket) do
    push(socket, "presence_state", Presence.list(socket))

    {:ok, _} =
      Presence.track(socket, socket.assigns.token, %{
        online_at: inspect(System.system_time(:second))
      })

    {:noreply, socket}
  end

  # Start the game in the room (resets the game to) [process on game engine]
  def handle_info(:start_game, socket) do
    broadcast!(socket, "game_event", %{command: "start_game"})
  end

  # Move a game piece from to [process on game engine]
  def handle_info({:move_from_to, %{from: _from, to: _to} = message}, socket) do
    broadcast(socket, "game_event", %{command: message})
  end

  #############
  # HANDLE IN #
  #############
  
  def handle_in("choose_game", game_name, socket) do
    new_context = Game.choose_game(socket.assigns.game, game_name)
    socket = assign(socket, :game, new_context)
    
    broadcast(socket, "context_update", new_context)
    {:noreply, socket}
  end

  def handle_in("add_player", player_number, socket) do
    new_context = Game.add_player(socket.assigns.game, player_number)
    socket = assign(socket, :game, new_context)
    
    broadcast(socket, "context_update", new_context)
    {:noreply, socket}
  end

  # Move a game piece from to [process on server]
  def handle_in("move_from_to", move, socket) do
    move =
      move
      |> keys_to_atoms()

    new_context = Game.move_from_to(socket.assigns.game, move)
    socket = assign(socket, :game, new_context)

    broadcast(socket, "context_update", new_context)
    {:noreply, socket}
  end

  defp keys_to_atoms(map) do
    map
    |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
  end
end
