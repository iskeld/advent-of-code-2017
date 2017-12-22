defmodule Advent do
  def solve(input) when is_binary(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse/1)
    |> Enum.map(&severity/1)
    |> Enum.sum
  end

  def severity({depth, range}) do
    if rem(depth, (range-1)*2) == 0 do
      depth*range
    else
      0
    end
  end
  
  def parse(line) when is_binary(line) do
    [depth, range] = String.split(line, ": ")
    {String.to_integer(depth), String.to_integer(range)}
  end
end
