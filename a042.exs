defmodule Advent do
  def solve(input) do
    input
    |> String.split(["\n", "\r"], trim: true) 
    |> Enum.filter(&is_valid/1)
    |> length()
  end

  def is_valid(line) when is_binary(line) do
    segments = String.split(line)
    result = Enum.reduce_while(segments, 1, fn (x, index) ->
      if (segments |> Enum.drop(index) |> Enum.any?(&anagram?(x, &1))) do
        {:halt, :invalid}
      else
        {:cont, index + 1}
      end
    end)
    result != :invalid
  end

  def anagram?(one, two) when is_binary(one) and is_binary(two) do
    list1 = one |> String.to_charlist() |> Enum.sort()
    list2 = two |> String.to_charlist() |> Enum.sort()
    list1 == list2
  end
end
