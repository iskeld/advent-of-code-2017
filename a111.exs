defmodule Advent do
  def solve(input) when is_binary(input) do
    directions = String.split(String.trim(input), ",", trim: true) |> Enum.map(&String.to_existing_atom/1)
    start = {0, 0, 0}
    final_hex = Enum.reduce(directions, start, fn (direction, location) -> move(direction, location) end)
    dist(start, final_hex)
  end

  def move(:n, {x, y, z}), do: {x, y + 1, z - 1}
  def move(:ne, {x, y, z}), do: {x + 1, y, z - 1}
  def move(:nw, {x, y, z}), do: {x - 1, y + 1, z}
  def move(:s, {x, y, z}), do: {x, y - 1, z + 1}
  def move(:se, {x, y, z}), do: {x + 1, y - 1, z}
  def move(:sw, {x, y, z}), do: {x - 1, y, z + 1}

  def dist({ax, ay, az}, {bx, by, bz}) do
    sum = abs(ax - bx) + abs(ay - by) + abs(az - bz)
    Integer.floor_div(sum, 2)
  end
end
