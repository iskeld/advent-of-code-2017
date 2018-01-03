defmodule Advent do
  @last_item 2017
  @last_step @last_item + 1

  def solve(steps) do
    step([0], 1, 0, steps)
  end

  def step(list, @last_step, index, _step), do: Enum.at(list, index + 1)
  def step(list, item, index, step) do
    new_index = rem(index + step, item) + 1
    list = List.insert_at(list, new_index, item)
    step(list, item + 1, new_index, step)
  end
end
