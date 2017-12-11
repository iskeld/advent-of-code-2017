defmodule Advent do
  def solve(input) when is_binary(input) do
    list = String.to_charlist(input)
    process(list, 0)
  end

  def process([], garbage_count), do: garbage_count
  def process([char | tail], garbage_count) do
    case char do
      ?{ -> process(tail, garbage_count)
      ?} -> process(tail, garbage_count)
      ?< -> process_garbage(tail, garbage_count)
      _ -> process(tail, garbage_count)
    end
  end

  def process_garbage([?! | [_canceled | tail]], garbage_count), do: process_garbage(tail, garbage_count)
  def process_garbage([char | tail], garbage_count) do
    case char do
      ?> -> process(tail, garbage_count)
      _ -> process_garbage(tail, garbage_count + 1)
    end
  end
end
