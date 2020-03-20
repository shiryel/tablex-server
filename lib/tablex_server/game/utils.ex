defmodule TablexServer.Game.Utils do
  @moduledoc """
  Functions that can be used in all games implementations
  """

  alias TablexServer.Game

  @doc """
  Set in the context the next player
  """
  @spec next_player(Game.t()) :: Game.t()
  def next_player(%{current_player: current_player, players: players} = context) do
    next_player =
      case Enum.find_index(players, fn x -> x == current_player end) do
        nil ->
          Enum.at(players, 0, 0)

        index ->
          Enum.at(players, index + 1, List.first(players))
      end

    %{context | current_player: next_player}
  end

  @doc """
  Add a new message to the message list
  """
  @spec add_message_to_player(Game.t(), bitstring, Game.message_event(), integer | [integer]) ::
          Game.t()
  def add_message_to_player(%{messages: messages} = context, message, event, player)
      when is_integer(player) do
    %{context | messages: messages ++ [%{players: [player], message: message, event: event}]}
  end

  def add_message_to_player(%{messages: messages} = context, message, event, players)
      when is_list(players) do
    %{context | messages: messages ++ [%{players: players, message: message, event: event}]}
  end

  @doc """
  Get the map position using a x y
  """
  @spec get_position_from_xy(Game.t(), integer, integer) :: integer
  def get_position_from_xy(%{size: %{width: width}} = _context, x, y) do
    y * width + x
  end
end
