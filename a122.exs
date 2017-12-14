defmodule Advent do
  def solve(input) when is_binary(input) do
    connections = get_connections(input)
    {_groups, count} = Map.keys(connections)
    |> Enum.reduce({connections, 0}, fn (x, {map, count}) ->
      if Map.has_key?(map, x) do
        {new_map, _} = visit(map, x, MapSet.new())
        {new_map, count + 1}
      else
        {map, count}
      end
    end)
    count
  end

  def get_connections(input), do: String.split(input, "\n", trim: true) |> Map.new(&parse/1)

  def parse(line) when is_binary(line) do
    [id, connected] = String.split(line, " <-> ")
    connected_ids = String.split(connected, ",") |> Enum.map(&String.to_integer(String.trim(&1)))
    {String.to_integer(id), connected_ids}
  end

  def visit(map, root, visited) do
    if MapSet.member?(visited, root) do
      {map, visited}
    else
      {children, map} = Map.pop(map, root)
      visited = MapSet.put(visited, root)
      Enum.reduce(children, {map, visited}, fn(x, {m, v}) -> visit(m, x, v) end)
    end
  end
end
