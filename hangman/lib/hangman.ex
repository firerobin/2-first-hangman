defmodule Hangman do
  @moduledoc """
  Documentation for Hangman.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Hangman.hello
      :world

  """
  defstruct(
    game_state: :initializing,
    turns_left: 7,
    letters: [],
    used: [],
    last_guess: "",
    word: []
  )

  def new_game() do
    word = Dictionary.random_word()
    word = Regex.split(~r{}, word, trim: true)
    word = List.delete(word, "\r")
    letters = Enum.reduce(word, [], fn (_, acc) -> ["_" | acc] end)
    %Hangman{word: word, letters: letters}
  end
  
  def tally(%Hangman{} = game) do
    Map.drop(game, [:word])
    |> Map.from_struct
    |> IO.inspect
  end
  
  def make_move(%Hangman{} = state, guess) do
    true = guess_valid?(guess)
    match_guess(MapSet.new(state.word) |> MapSet.member?(guess),
                MapSet.new(state.used) |> MapSet.member?(guess))
    |> handle_result(guess, state)
  end

  defp guess_valid?(string) do
    Regex.match?(~r/^[a-zA-Z]$/, string)
  end
  
  defp match_guess(false, false), do: :bad_guess
  defp match_guess(true, false), do: :good_guess
  defp match_guess(_, true), do: :already_used
  
  defp update_letters({:ok, guess}, index, guess, %Hangman{word: word, letters: letters} = state) do
    new_letters = List.replace_at(letters, index, guess)
    Enum.fetch(word, index + 1) |> update_letters(index + 1, guess, %Hangman{state | letters: new_letters})
  end
  
  defp update_letters({:ok, _letter}, index, guess, %Hangman{word: word} = state) do
    Enum.fetch(word, index + 1) |> update_letters(index + 1, guess, state)
  end
  
  defp update_letters(:error, _index, _guess, %Hangman{} = state), do: state    
  
  defp handle_result(:bad_guess, guess, %Hangman{used: used, turns_left: turns_left} = state) do
    new_used = Enum.concat(used, [guess]) |> Enum.sort
    %Hangman{state | game_state: :bad_guess, last_guess: guess, used: new_used, turns_left: turns_left - 1}
    |> game_over?
  end
  
  defp handle_result(:good_guess, guess, %Hangman{word: word, used: used} = state) do
    new_used = Enum.concat(used, [guess]) |> Enum.sort
    new_state = Enum.fetch(word, 0) |> update_letters(0, guess, state)
    game_over?(%Hangman{new_state | game_state: :good_guess, last_guess: guess, used: new_used})
  end
  
  defp handle_result(:already_used, _guess, %Hangman{} = state) do
    new_state = %Hangman{state | game_state: :already_used}
    {new_state, tally(new_state)}
  end
  
  defp game_over?(%Hangman{word: match, letters: match} = state) do
    new_state = %Hangman{state | game_state: :won}
    {new_state, tally(new_state)}
  end
  
  defp game_over?(%Hangman{turns_left: 0, word: word} = state) do
    new_state = %Hangman{state | game_state: :lost, letters: word}
    {new_state, tally(new_state)}
  end
  
  defp game_over?(%Hangman{} = state), do: {state, tally(state)}
end
