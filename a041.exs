defmodule Advent do
  def solve(input) do
    input
    |> String.split(["\n", "\r"], trim: true) 
    |> Enum.filter(&is_valid/1)
    |> length()
  end

  def is_valid(line) when is_binary(line) do
    segments = String.split(line)
    set = MapSet.new(segments)
    length(segments) == MapSet.size(set)
  end
end
