defmodule Advent do
  @last_item 50000000
  @last_step @last_item + 1

  def solve(steps) do
    step(nil, 1, 0, steps)
  end

  def step(result, @last_step, _index, _step), do: result
  def step(result, item, index, step) do
    new_index = rem(index + step, item) + 1
    result = if new_index == 1, do: item, else: result
    step(result, item + 1, new_index, step)
  end
end
