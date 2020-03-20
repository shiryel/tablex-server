defmodule TablexServer.Game.TicTacToe do
  @moduledoc """
  This tic-tac-toe implementation works with any size of map, the sides only have to be equal, and works with 2 or more players (separing with pair and odd, where the players in this situation play in cycle rounds)

  The pieces used by this implementation area:
  - 0 to empty tile
  - 1 to player 2 pieces
  - 2 to player 1 pieces

  Winner condition:
  - One full column, array or diagonal
  """
  @behaviour TablexServer.Game
  alias TablexServer.Game.Utils

  @impl true
  def new_game(context) do
    %{height: h, width: w} = context.size

    new_map =
      Stream.repeatedly(fn -> 0 end)
      |> Enum.take(h * w)

    %{context | map: new_map}
  end

  # TODO: I have the idea of the click_on/2 after making the 200 lines of tests and implementing this using the move_from_to/2, so... when I have pacience I'll refactory this module, BUT NOT NOW! 
  @impl true
  def click_on(context, position) do
    move_from_to(context, %{from: nil, to: position})
  end

  @impl true
  # Get first player to play
  def move_from_to(%{current_player: 0} = context, move) do
    %{current_player: current_player} = context = Utils.next_player(context)

    if current_player == 0 do
      Utils.add_message_to_player(context, "None players on the room", :warning, 0)
    else
      move_from_to(context, move)
    end
  end

  # only validate
  def move_from_to(context, %{to: nil}) do
    context
    |> verify_winner()
  end

  # Validate, make the move, change_player and verify winner
  def move_from_to(context, move) do
    context
    |> validate_and_move(move)
    |> verify_winner()
  end

  # validate move
  # make move
  # set to next player
  defp validate_and_move(
         %{current_player: player, map: map} = context,
         %{to: %{x: x, y: y}}
       ) do
    position = Utils.get_position_from_xy(context, x, y)

    if any_piece?(context, position) do
      Utils.add_message_to_player(context, "Invalid action", :warning, player)
    else
      new_map = List.replace_at(map, position, player)

      context
      |> Map.put(:map, new_map)
      |> Utils.next_player()
    end
  end

  defp any_piece?(%{map: map} = _context, index) do
    case Enum.at(map, index, 0) do
      0 ->
        false

      _ ->
        true
    end
  end

  # Add messages to winner/looser if any
  defp verify_winner(
         %{map: map, players: players, size: %{height: height, width: width}} = context
       ) do
    with false <- verify_rows(map, width),
         false <- verify_columns(map, height, width),
         false <- verify_diagonal(map, height, width) do
      context
    else
      # 1 to player 2 pieces
      # 2 to player 1 pieces
      {true, player_piece} ->
        loosers = Enum.filter(players, fn x -> x != player_piece end)

        context
        |> Utils.add_message_to_player("You win", :victory, player_piece)
        |> Utils.add_message_to_player("You lose", :defeat, loosers)

      _ ->
        context
    end
  end

  # returns:
  # {true, player_piece}
  # false
  defp verify_rows([], _width), do: false

  defp verify_rows(map, width) do
    {row, next} = Enum.split(map, width)

    if List.first(row) != 0 &&
         Enum.all?(row, fn x -> x == List.first(row) end) do
      {true, List.first(row)}
    else
      verify_rows(next, width)
    end
  end

  # returns:
  # {true, player_piece}
  # false
  # TODO: try to understand how this is passing the test, SERIOUS!
  defp verify_columns(map, height, width, width_count \\ 0)
  defp verify_columns(_map, _height, width, width), do: false

  defp verify_columns(map, height, width, width_count) do
    column =
      for h <- 1..height do
        Enum.at(map, h * width - width_count - 1)
      end

    if List.first(column) != 0 &&
         Enum.all?(column, fn x -> x == List.first(column) end) do
      {true, List.first(column)}
    else
      verify_columns(map, height, width, width_count + 1)
    end
  end

  # returns:
  # {true, player_piece}
  # false
  defp verify_diagonal(map, height, width) do
    # x, 0, 0
    # 0, x, 0
    # 0, 0, x
    diagonal1 =
      for h <- 0..(height - 1) do
        Enum.at(map, h * width + h)
      end

    # 0, 0, x
    # 0, x, 0
    # x, 0, 0
    diagonal2 =
      for h <- 1..height do
        Enum.at(map, h * width - h)
      end

    cond do
      List.first(diagonal1) != 0 &&
          Enum.all?(diagonal1, fn x -> x == List.first(diagonal1) end) ->
        {true, List.first(diagonal1)}

      List.first(diagonal2) != 0 &&
          Enum.all?(diagonal2, fn x -> x == List.first(diagonal2) end) ->
        {true, List.first(diagonal2)}

      true ->
        false
    end
  end

  @impl true
  def selected_piece(context, _position) do
    context
  end
end
