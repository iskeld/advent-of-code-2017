defmodule Advent do
  def solve(input) when is_binary(input) do
    list = input
    |> String.split() 
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()

    solve(list, length(list), Map.new(), 0)
  end
  
  def solve(list, size, memory, cycles) when is_list(list) do
    if prev_cycles = Map.get(memory, list) do
      cycles - prev_cycles
    else
      new_list = distirbute(list, size)
      new_memory = Map.put(memory, list, cycles)
      solve(new_list, size, new_memory, cycles + 1)
    end
  end

  def distirbute(list, size) when is_list(list) do
    {points, index} = Enum.max_by(list, fn {element, _index} -> element end)

    base = Integer.floor_div(points, size)
    elements = Integer.mod(points, size)

    sum = index + elements

    if sum >= size do
      lower = sum-size
      upper = index + 1

      Enum.map(list, fn
        {^points, ^index} -> if index > lower and index < upper, do: {base, index}, else: {base + 1, index}
        {element, idx} when idx > lower and idx < upper -> {base + element, idx}
        {element, idx} -> {element + base + 1, idx}
      end)
    else
      lower = index + 1
      upper = index + elements

      Enum.map(list, fn
        {^points, ^index} -> {base, index}
        {element, idx} when idx < lower or idx > upper -> {element + base, idx}
        {element, idx} -> {element + base + 1, idx}
      end)
    end
  end
end
