defmodule TablexServer.Game.UtilsTest do
  use TablexServer.GameCase, async: true
  alias TablexServer.Game
  alias TablexServer.Game.Utils

  setup_all do
    context = Game.new()

    {:ok, context: context}
  end

  test ~s|`next_player/1` will set for 0 case the player is 0 and the list of players is 0|,
       %{context: context} do
    %{current_player: current_player} = Utils.next_player(context)
    assert current_player == 0
  end

  test ~s|`next_player/1` will set for first player case the player is 0 and the list, and keep in the first player if the list only have him|,
       %{context: context} do
    context =
      context
      |> Game.add_player(1)

    %{current_player: current_player} = context = Utils.next_player(context)
    assert current_player == 1

    %{current_player: current_player} = Utils.next_player(context)
    assert current_player == 1
  end

  test ~s|`next_player/1` will rotate betwhen the players in the player list|,
       %{context: context} do
    context =
      context
      |> Game.add_player(1)
      |> Game.add_player(2)
      |> Game.add_player(3)
      |> Game.add_player(4)

    cycle = Stream.cycle(1..4)

    # cycle 40 times in the list
    Enum.reduce(Enum.take(cycle, 40), context, fn x, context ->
      %{current_player: current_player} = context = Utils.next_player(context)
      assert current_player == x
      context
    end)
  end

  test ~s|`add_message_to_player/4` will add a new message at the end of the list of messages|, %{
    context: context
  } do
    # Add first message
    %{messages: messages} =
      context =
      context
      |> Utils.add_message_to_player("test", :warning, 0)

    assert messages == [%{players: [0], message: "test", event: :warning}]

    # Add another one
    %{messages: messages} =
      context
      |> Utils.add_message_to_player("test2", :victory, 1)

    assert messages == [
             %{players: [0], message: "test", event: :warning},
             %{players: [1], message: "test2", event: :victory}
           ]
  end

  test ~s|`get_position_from_xy/3` will get the position relative to map sizes|, %{
    context: context
  } do
    context =
      context
      |> Map.put(:size, %{height: 3, width: 3})

    assert Utils.get_position_from_xy(context, 0, 0) == 0
    assert Utils.get_position_from_xy(context, 1, 1) == 4
    assert Utils.get_position_from_xy(context, 0, 2) == 6
    assert Utils.get_position_from_xy(context, 2, 2) == 8
  end
end
