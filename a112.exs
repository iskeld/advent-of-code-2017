defmodule Advent do
  def solve(input) when is_binary(input) do
    directions = String.split(String.trim(input), ",", trim: true) |> Enum.map(&String.to_existing_atom/1)
    start = {0, 0, 0}
    {distances, _final} = Enum.map_reduce(directions, start, fn (direction, location) -> move_with_dist(direction, location) end)
    Enum.max(distances)
  end

  def move_with_dist(direction, location) do
    new_loc = move(direction, location)
    {dist(new_loc), new_loc}
  end

  def move(:n, {x, y, z}), do: {x, y + 1, z - 1}
  def move(:ne, {x, y, z}), do: {x + 1, y, z - 1}
  def move(:nw, {x, y, z}), do: {x - 1, y + 1, z}
  def move(:s, {x, y, z}), do: {x, y - 1, z + 1}
  def move(:se, {x, y, z}), do: {x + 1, y - 1, z}
  def move(:sw, {x, y, z}), do: {x - 1, y, z + 1}

  def dist({x, y, z}), do: abs(x) + abs(y) + abs(z) |> Integer.floor_div(2)
end
