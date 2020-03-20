defmodule TablexServer.GameTest do
  use TablexServer.GameCase, async: true
  alias TablexServer.Game

  test ~s|`new/0` create a context that start with the game "__choosing__" and zero players (only values that is used in the __choosing__ screen with the client)| do
    %{game: game, players: players} = Game.new()
    assert game == "__choosing__"
    assert players == []
  end

  test ~s|`add_player/2` add a new player on the tail of the context| do
    %{players: players} =
      context =
      Game.new()
      |> Game.add_player(1)

    assert players == [1]

    %{players: players} =
      context
      |> Game.add_player(2)

    assert players == [1, 2]
  end

  test ~s|`new_game/1` will do nothing in case that a game have not ben selected| do
    %{game: game} =
      Game.new()
      |> Game.new_game()

    assert game == "__choosing__"
  end

  test ~s|`choose_game/2` will default to "__choosing__" case the game does not exist| do
    %{game: game} =
      Game.new()
      |> Game.choose_game("__TEST:WILL_NEVER_EXISTS^^^serious__")
      |> Game.new_game()
      |> Game.move_from_to(%{from: %{x: 0, y: 0}, to: %{x: 0, y: 0}})

    assert game == "__choosing__"
  end

  test ~s|`set_map_size/3` will set to the correct map size| do
    %{size: %{height: height, width: width}} =
      Game.new()
      |> Game.choose_game("tic-tac-toe")
      |> Game.set_map_size(3, 3)
      |> Game.new_game()
      |> Game.click_on(%{x: 0, y: 0})

    assert height == 3
    assert width == 3
  end

  test ~s|`choose_game/2` will look at the @game_list and set the `:game` and `:game_module`| do
    %{game: game, game_module: game_module} =
      Game.new()
      |> Game.choose_game("tic-tac-toe")
      |> Game.new_game()
      |> Game.click_on(%{x: 0, y: 0})

    assert game == "tic-tac-toe"
    assert game_module == TablexServer.Game.TicTacToe
  end
end
