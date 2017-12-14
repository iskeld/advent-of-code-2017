defmodule Advent do
  def solve(input) when is_binary(input) do
    data = String.split(input, "\n", trim: true)
    |> Map.new(&parse/1)
    |> visit(0, MapSet.new())
    |> MapSet.size()
  end

  def parse(line) when is_binary(line) do
    [id, connected] = String.split(line, " <-> ")
    connected_ids = String.split(connected, ",") |> Enum.map(&String.to_integer(String.trim(&1)))
    {String.to_integer(id), connected_ids}
  end

  def visit(map, root, visited) do
    if MapSet.member?(visited, root) do
      visited
    else
      children = map[root]
      visited = MapSet.put(visited, root)
      Enum.reduce(children, visited, fn(x, acc) -> visit(map, x, acc) end)
    end
  end
end
