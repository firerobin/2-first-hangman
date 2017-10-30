defmodule Hangman do
  
  defdelegate make_move(game, guess), to: Hangman.Game
  defdelegate new_game(),             to: Hangman.Game
  defdelegate tally(game),            to: Hangman.Game

end