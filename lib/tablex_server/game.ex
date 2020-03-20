defmodule TablexServer.Game do
  @moduledoc """
  Defines a standard struct to be used by the internal table games as a context to main APIs functions that delegates the context to the respective game implementation and function

  Notes:
  - Some games can delegate the size set for the client (like: Velha), others can specific a unic size for game (like: Chess)
  - When `:game` is in "__choosing__" the client will only set `:size`, `:players` and `:game`
  - Messages setted in the `:messages` will be consumed by the client and deleted
  - `:current_player` is to be setted in the game implementation, because a player can make a not allowed move and have to play again
  - `:map` is the souce of truth of the current state of the game
  - `:selected_piece` and `:moves_alowed` are optional per game

  In the client, we have a list of pieces, and this list is what defines what piece a player will use, the implementation who will care of this. The current list is:
  - 0 : empty
  - 1 : white circle
  - 2 : black circle

  You can make validations to make one player dont mess with other player pieces
  """

  @game_list [{"tic-tac-toe", __MODULE__.TicTacToe}]

  # The Game behavior for implementations (of the `delegate/1`)
  @callback new_game(t) :: t
  @callback click_on(t, position) :: t
  @callback move_from_to(t, move) :: t
  @callback selected_piece(t, position) :: t

  # The keys that you go to the client
  @derive {Jason.Encoder,
           only: [
             :game,
             :size,
             :map,
             :selected_piece,
             :moves_alowed,
             :history,
             :current_player,
             :players,
             :messages
           ]}
  defstruct game: "__choosing__",
            game_module: nil,
            size: %{height: 0, width: 0},
            map: [],
            selected_piece: nil,
            moves_alowed: nil,
            history: [],
            current_player: 0,
            players: [],
            messages: []

  @typedoc """
  `Game` basic struct
  Responsabilities:
    - The `:size` of the table
    - The `:history` of moves for games were the last moves are important (like go), and to (maybe) implement 'undus', WARNING: to keep efficient the last move is inserted in the head
    - The current `map` with the pieces in their respective positions (calculation: (y * width) + x ), the map keeps the piece 0 for empty space and the others numbers corresponding the player_number in the `:current_player`
    - The `:current_player` making the move, where is used to get the next player from the `:players`, note that the "player 0" says that the game dont have a player to do the move
    - The `:players` is a list with all the players
    - The `:game` is what determine what implementation is going to handle this struct
    - The `:messages` will spawn messages with custom modals to the players
  """
  @type t :: %__MODULE__{
          # internal
          game_module: atom | nil,
          # table
          game: bitstring,
          size: %{height: integer, width: integer},
          map: [integer],
          selected_piece: position | nil,
          moves_alowed: [integer] | nil,
          history: [move],
          # players
          current_player: integer,
          players: [integer],
          messages: [%{players: [integer], message: bitstring, event: message_event}]
        }

  @typedoc """
  A specific XY position, used in moves and clicks (to see where the player can move the current piece, if the game returns the `:moves_alowed` with a list of integer [like the `:map`])
  """
  @type position :: %{x: integer, y: integer}

  @typedoc """
  The moves from the player, used in the current move and in the history of moves
  Note: case the `:from` or `:to` be nil, then the piece is being added or removed from the table
  """
  @type move :: %{from: position | nil, to: position | nil}

  @typedoc """
  Events to spawn custom messages
  """
  @type message_event :: :warning | :victory | :defeat

  require Logger
  alias __MODULE__.Utils

  @doc """
  Creates a default context
  """
  @spec new :: t
  def new do
    %__MODULE__{}
  end

  @doc """
  Choose a game, puting the game name on `:game` and your module in `:game_module`
  """
  @spec choose_game(t, bitstring) :: t
  for {game_name, game_module} <- @game_list do
    def choose_game(context, unquote(game_name)) do
      context
      |> Map.update(:game, nil, fn _x -> unquote(game_name) end)
      |> Map.update(:game_module, nil, fn _x -> unquote(game_module) end)
    end
  end

  # case the game doenst exist in @game_list
  def choose_game(context, game_name) do
    Logger.warn(
      "The game `#{game_name}` does not exist or is not set in the @game_list of the #{__MODULE__} module"
    )

    context
    |> Map.update(:game, nil, fn _x -> "__choosing__" end)
    |> Map.update(:game_module, nil, fn _x -> nil end)
    |> Utils.add_message_to_player("This game does not exist", :warning, 0)
  end

  @doc """
  Set the map size of the game
  """
  @spec set_map_size(t, integer, integer) :: t
  def set_map_size(context, height, width) do
    Map.update(context, :size, nil, fn _x -> %{height: height, width: width} end)
  end

  @doc """
  Add a new players to the context
  """
  @spec add_player(t, integer) :: t
  def add_player(context, player) do
    Map.update(context, :players, [], fn x -> x ++ [player] end)
  end

  @doc """
    Delegate a new_game on to a implementation in the module defined in `choose_game/2`
  """
  @spec new_game(t) :: t
  def new_game(%{game_module: module} = context) do
    if module do
      module.new_game(context)
    else
      context
    end
  end

  @doc """
    Delegate a click on a tile to a implementation in the module defined in `choose_game/2`
  """
  @spec click_on(t, position) :: t
  def click_on(%{game_module: module} = context, position) do
    if module do
      module.click_on(context, position)
    else
      context
    end
  end

  @doc """
    Delegate a move_from_to on a tile to a implementation in the module defined in `choose_game/2`
  """
  @spec move_from_to(t, move) :: t
  def move_from_to(%{game_module: module} = context, move) do
    if module do
      module.move_from_to(context, move)
    else
      context
    end
  end
end
