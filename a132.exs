defmodule Advent do
  def solve(input) when is_binary(input) do
    # TODO: wrong, brute-force solution!
    layers = input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse/1)

    Stream.iterate(1, &(&1+1))
    |> Enum.find(nil, fn x -> can_pass?(layers, x) end)
  end

  def can_pass?(layers, time) when is_list(layers) do
    Enum.all?(layers, &can_pass?(&1, time))
  end

  def can_pass?({depth, range}, time) do
    rem(depth + time, (range-1)*2) != 0
  end

  def parse(line) when is_binary(line) do
    [depth, range] = String.split(line, ": ")
    {String.to_integer(depth), String.to_integer(range)}
  end
end
