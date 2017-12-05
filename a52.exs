defmodule Advent do
  def solve(input) do
    input 
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> :array.from_list()
    |> visit(0, 0)
  end

  def visit(array, index, steps) do
    if index >= :array.size(array) do
      steps
    else
      offset = :array.get(index, array)
      offset_diff = if offset >= 3, do: -1, else: 1
      :array.set(index, offset + offset_diff, array) |> visit(index + offset, steps + 1)
    end
  end
end
