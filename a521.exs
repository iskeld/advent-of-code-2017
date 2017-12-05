defmodule Advent do
  def solve(input) do
    map = input 
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Map.new(fn({element, index}) -> {index, element} end)
    visit(map, :maps.size(map), 0, 0)
  end

  def visit(map, size, index, steps) do
    if index >= size do
      steps
    else
      offset = map[index]
      offset_diff = if offset >= 3, do: -1, else: 1
      Map.put(map, index, offset + offset_diff) |> visit(size, index + offset, steps + 1)
    end
  end
end
