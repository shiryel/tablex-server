defmodule TablexServer.Game.TicTacToeTest do
  use TablexServer.GameCase, async: true
  alias TablexServer.Game

  setup_all do
    context =
      Game.new()
      |> Game.choose_game("tic-tac-toe")
      |> Game.set_map_size(3, 3)

    {:ok, context: context}
  end

  describe "Game any size" do
    test ~s|`new_game/1` will generate a empty map (0 is empty to client) of the size of `:size`|,
         %{context: context} do
      %{height: h, width: w} = context.size

      expected =
        Stream.repeatedly(fn -> 0 end)
        |> Enum.take(h * w)

      result =
        Game.new_game(context)
        |> Map.get(:map)

      assert expected == result
    end
  end

  describe "Game 3x3" do
    test ~s|`move_from_to/2` only set new pieces on the `:map`|, %{context: context} do
      context =
        Game.new_game(context)
        |> Game.add_player(1)
        |> Game.add_player(2)
        |> Game.move_from_to(%{from: nil, to: %{x: 0, y: 0}})

      assert context.map == [1, 0, 0, 0, 0, 0, 0, 0, 0]
    end

    test ~s|`move_from_to/2` genereta a :warning message in invalid moves|, %{context: context} do
      context =
        Game.new_game(context)
        |> Game.add_player(1)
        |> Game.add_player(2)
        |> Game.move_from_to(%{from: nil, to: %{x: 0, y: 0}})
        |> Game.move_from_to(%{from: nil, to: %{x: 0, y: 0}})

      assert context.messages == [%{event: :warning, message: "Invalid action", players: [2]}]
    end

    test ~s|`move_from_to/2` will send message in case of a column(0) win condition|, %{
      context: context
    } do
      context =
        Game.new_game(context)
        |> Game.add_player(1)
        |> Game.add_player(2)
        |> Game.move_from_to(%{from: nil, to: nil})

      assert context.messages == []

      context =
        context
        |> Game.move_from_to(%{from: nil, to: %{x: 0, y: 0}})
        |> Game.move_from_to(%{from: nil, to: %{x: 1, y: 0}})
        |> Game.move_from_to(%{from: nil, to: %{x: 0, y: 1}})
        |> Game.move_from_to(%{from: nil, to: %{x: 1, y: 1}})
        |> Game.move_from_to(%{from: nil, to: %{x: 0, y: 2}})

      assert context.map == [1, 2, 0, 1, 2, 0, 1, 0, 0]

      assert context.messages == [
               %{players: [1], message: "You win", event: :victory},
               %{players: [2], message: "You lose", event: :defeat}
             ]
    end

    test ~s|`move_from_to/2` will send message in case of a column(1) win condition|, %{
      context: context
    } do
      context =
        Game.new_game(context)
        |> Game.add_player(1)
        |> Game.add_player(2)
        |> Game.move_from_to(%{from: nil, to: nil})

      assert context.messages == []

      context =
        context
        |> Game.move_from_to(%{from: nil, to: %{x: 0, y: 0}})
        |> Game.move_from_to(%{from: nil, to: %{x: 1, y: 0}})
        |> Game.move_from_to(%{from: nil, to: %{x: 0, y: 1}})
        |> Game.move_from_to(%{from: nil, to: %{x: 1, y: 1}})
        |> Game.move_from_to(%{from: nil, to: %{x: 2, y: 2}})
        |> Game.move_from_to(%{from: nil, to: %{x: 1, y: 2}})

      assert context.map == [1, 2, 0, 1, 2, 0, 0, 2, 1]

      assert context.messages == [
               %{players: [2], message: "You win", event: :victory},
               %{players: [1], message: "You lose", event: :defeat}
             ]
    end

    test ~s|`move_from_to/2` will send message in case of a column(2) win condition|, %{
      context: context
    } do
      context =
        Game.new_game(context)
        |> Game.add_player(1)
        |> Game.add_player(2)
        |> Game.move_from_to(%{from: nil, to: nil})

      assert context.messages == []

      context =
        context
        |> Game.move_from_to(%{from: nil, to: %{x: 0, y: 0}})
        |> Game.move_from_to(%{from: nil, to: %{x: 1, y: 0}})
        |> Game.move_from_to(%{from: nil, to: %{x: 0, y: 1}})
        |> Game.move_from_to(%{from: nil, to: %{x: 1, y: 1}})
        |> Game.move_from_to(%{from: nil, to: %{x: 2, y: 2}})
        |> Game.move_from_to(%{from: nil, to: %{x: 1, y: 2}})

      assert context.map == [1, 2, 0, 1, 2, 0, 0, 2, 1]

      assert context.messages == [
               %{players: [2], message: "You win", event: :victory},
               %{players: [1], message: "You lose", event: :defeat}
             ]
    end

    test ~s|`move_from_to/2` will send message in case of a column(3) win condition with 3 players|,
         %{
           context: context
         } do
      context =
        Game.new_game(context)
        |> Game.add_player(1)
        |> Game.add_player(2)
        |> Game.add_player(3)
        |> Game.move_from_to(%{from: nil, to: nil})

      assert context.messages == []

      context =
        context
        |> Game.move_from_to(%{from: nil, to: %{x: 2, y: 0}})
        |> Game.move_from_to(%{from: nil, to: %{x: 1, y: 0}})
        |> Game.move_from_to(%{from: nil, to: %{x: 1, y: 1}})
        |> Game.move_from_to(%{from: nil, to: %{x: 2, y: 1}})
        |> Game.move_from_to(%{from: nil, to: %{x: 1, y: 2}})
        |> Game.move_from_to(%{from: nil, to: %{x: 0, y: 1}})
        |> Game.move_from_to(%{from: nil, to: %{x: 2, y: 2}})

      assert context.messages == [
               %{players: [1], message: "You win", event: :victory},
               %{players: [2, 3], message: "You lose", event: :defeat}
             ]
    end

    test ~s|`move_from_to/2` will send message in case of a row(0) win condition|, %{
      context: context
    } do
      context =
        Game.new_game(context)
        |> Game.add_player(1)
        |> Game.add_player(2)
        |> Game.move_from_to(%{from: nil, to: nil})

      assert context.messages == []

      context =
        context
        |> Game.move_from_to(%{from: nil, to: %{x: 0, y: 0}})
        |> Game.move_from_to(%{from: nil, to: %{x: 2, y: 2}})
        |> Game.move_from_to(%{from: nil, to: %{x: 1, y: 0}})
        |> Game.move_from_to(%{from: nil, to: %{x: 2, y: 1}})
        |> Game.move_from_to(%{from: nil, to: %{x: 2, y: 0}})

      assert context.map == [1, 1, 1, 0, 0, 2, 0, 0, 2]

      assert context.messages == [
               %{players: [1], message: "You win", event: :victory},
               %{players: [2], message: "You lose", event: :defeat}
             ]
    end

    test ~s|`move_from_to/2` will send message in case of a row(1) win condition with 3 players|,
         %{
           context: context
         } do
      context =
        Game.new_game(context)
        |> Game.add_player(1)
        |> Game.add_player(2)
        |> Game.add_player(3)
        |> Game.move_from_to(%{from: nil, to: nil})

      assert context.messages == []

      context =
        context
        |> Game.move_from_to(%{from: nil, to: %{x: 0, y: 0}})
        |> Game.move_from_to(%{from: nil, to: %{x: 0, y: 2}})
        |> Game.move_from_to(%{from: nil, to: %{x: 2, y: 2}})
        |> Game.move_from_to(%{from: nil, to: %{x: 1, y: 0}})
        |> Game.move_from_to(%{from: nil, to: %{x: 0, y: 1}})
        |> Game.move_from_to(%{from: nil, to: %{x: 2, y: 1}})
        |> Game.move_from_to(%{from: nil, to: %{x: 2, y: 0}})

      assert context.map == [1, 1, 1, 2, 0, 3, 2, 0, 3]

      assert context.messages == [
               %{players: [1], message: "You win", event: :victory},
               %{players: [2, 3], message: "You lose", event: :defeat}
             ]
    end

    test ~s|`move_from_to/2` will send message in case of a row(2) win condition with 4 players|,
         %{
           context: context
         } do
      context =
        Game.new_game(context)
        |> Game.add_player(1)
        |> Game.add_player(2)
        |> Game.add_player(3)
        |> Game.add_player(4)
        |> Game.move_from_to(%{from: nil, to: nil})

      assert context.messages == []

      context =
        context
        |> Game.move_from_to(%{from: nil, to: %{x: 0, y: 0}})
        |> Game.move_from_to(%{from: nil, to: %{x: 0, y: 2}})
        |> Game.move_from_to(%{from: nil, to: %{x: 1, y: 2}})
        |> Game.move_from_to(%{from: nil, to: %{x: 2, y: 2}})
        |> Game.move_from_to(%{from: nil, to: %{x: 1, y: 0}})
        |> Game.move_from_to(%{from: nil, to: %{x: 0, y: 1}})
        |> Game.move_from_to(%{from: nil, to: %{x: 1, y: 1}})
        |> Game.move_from_to(%{from: nil, to: %{x: 2, y: 1}})
        |> Game.move_from_to(%{from: nil, to: %{x: 2, y: 0}})

      assert context.map == [1, 1, 1, 2, 3, 4, 2, 3, 4]

      assert context.messages == [
               %{players: [1], message: "You win", event: :victory},
               %{players: [2, 3, 4], message: "You lose", event: :defeat}
             ]
    end

    test ~s|`move_from_to/2` will send message in case of a diagonal(1) win condition|, %{
      context: context
    } do
      context =
        Game.new_game(context)
        |> Game.add_player(1)
        |> Game.add_player(2)
        |> Game.move_from_to(%{from: nil, to: nil})

      assert context.messages == []

      context =
        context
        |> Game.move_from_to(%{from: nil, to: %{x: 0, y: 0}})
        |> Game.move_from_to(%{from: nil, to: %{x: 1, y: 2}})
        |> Game.move_from_to(%{from: nil, to: %{x: 1, y: 1}})
        |> Game.move_from_to(%{from: nil, to: %{x: 2, y: 1}})
        |> Game.move_from_to(%{from: nil, to: %{x: 2, y: 2}})

      assert context.map == [1, 0, 0, 0, 1, 2, 0, 2, 1]

      assert context.messages == [
               %{players: [1], message: "You win", event: :victory},
               %{players: [2], message: "You lose", event: :defeat}
             ]
    end

    test ~s|`move_from_to/2` will send message in case of a diagonal(2) win condition|, %{
      context: context
    } do
      context =
        Game.new_game(context)
        |> Game.add_player(1)
        |> Game.add_player(2)
        |> Game.move_from_to(%{from: nil, to: nil})

      assert context.messages == []

      context =
        context
        |> Game.move_from_to(%{from: nil, to: %{x: 2, y: 0}})
        |> Game.move_from_to(%{from: nil, to: %{x: 1, y: 2}})
        |> Game.move_from_to(%{from: nil, to: %{x: 1, y: 1}})
        |> Game.move_from_to(%{from: nil, to: %{x: 2, y: 1}})
        |> Game.move_from_to(%{from: nil, to: %{x: 0, y: 2}})

      assert context.map == [0, 0, 1, 0, 1, 2, 1, 2, 0]

      assert context.messages == [
               %{players: [1], message: "You win", event: :victory},
               %{players: [2], message: "You lose", event: :defeat}
             ]
    end
  end
end
