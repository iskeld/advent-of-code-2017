defmodule Advent do
  def solve(input) when is_binary(input) do
    list = String.to_charlist(input)
    process(list, 0, 0)
  end

  def process([], _group_score, score), do: score
  def process([char | tail], group_score, score) do
    case char do
      ?{ -> process(tail, group_score + 1, score)
      ?} -> process(tail, group_score - 1, score + group_score)
      ?< -> process_garbage(tail, group_score, score)
      _ -> process(tail, group_score, score)
    end
  end

  def process_garbage([?! | [_canceled | tail]], group_score, score), do: process_garbage(tail, group_score, score)
  def process_garbage([char | tail], group_score, score) do
    case char do
      ?> -> process(tail, group_score, score)
      _ -> process_garbage(tail, group_score, score)
    end
  end
end
