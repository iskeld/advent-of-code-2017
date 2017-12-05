defmodule Advent do
  def solve(input) do
    list = input 
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    visit([], list, 0)
  end

  def visit(_back, [], steps) do
    steps
  end
  def visit(back, [offset | tail], steps) do
    offset_increment = if offset >= 3, do: -1, else: 1
    case offset do
      0 -> visit(back, [offset + 1 | tail], steps + 1)
      offset when offset > 0 -> 
        {left, new_head} = Enum.split([offset + offset_increment | tail], offset)
        visit(back ++ left, new_head, steps + 1)
      offset when offset < 0 ->
        {new_back, right} = Enum.split(back, offset)
        visit(new_back, right ++ [offset + offset_increment | tail], steps + 1)
    end
  end
end
