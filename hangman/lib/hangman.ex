defmodule Hangman do
  
  defdelegate make_move(game, guess), Hangman.Game
  defdelegate new_game(),             Hangman.Game
  defdelegate tally(game),            Hangman.Game

end