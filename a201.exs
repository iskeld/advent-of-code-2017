defmodule Advent do
  def solve(input) do
    parse(input) 
  end

  def parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.with_index()
    |> Enum.sort(fn ({part, _}, {part2, _}) -> compare_acceleration(part, part2) end)
    |> Enum.take(1)
  end

  def parse_line(input) when is_binary(input) do
    [p, v, a] =
      Regex.run(~r"p=<(.*)>, v=<(.*)>, a=<(.*)>", input)
      |> Enum.drop(1)
      |> Enum.map(&parse_unit/1)
    {p, v, a}
  end

  def parse_unit(input) do
    [x, y, z] = String.split(input, ",")
                |> Enum.map(&String.to_integer/1)
    {x, y, z}
  end

  def compare_acceleration({_, _, a1}, {_, _, a2}), do: manhattan(a1) <= manhattan(a2)

  def manhattan({x, y, z}), do: abs(x) + abs(y) + abs(z)
end
