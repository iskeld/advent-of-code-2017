defmodule Advent do
  defmodule State do
    defstruct [:node, :direction, :infections, :infections_count]
  end

  def solve(input) do
    infections = parse(input)
    state = %State{node: {0,0}, direction: :north, infections: infections, infections_count: 0}
    burst(state, 0)
  end

  def parse(input) do
    lines = String.split(input, "\n", trim: true)
    size = length(lines)
    max = div(size - 1, 2)
    {infected, _} = Enum.reduce(lines, {MapSet.new(), max}, fn (line, {infected, y}) -> {parse_line(line, {-max, y}, infected), y - 1} end)
    infected
  end

  def parse_line(<<>>, _x, infected), do: infected
  def parse_line(<<c, rest :: binary>>, loc = {x, y}, infected) do
    infected = case c do
      ?# -> MapSet.put(infected, loc)
      _ -> infected
    end
    parse_line(rest, {x + 1, y}, infected)
  end

  def burst(state, count) when count >= 10000, do: state
  def burst(state = %State{node: n, direction: direction, infections: infections, infections_count: inf_count}, count) do
    {turn, op, infections_increment} = if current_node_infected?(state) do
      {:right, &MapSet.delete/2, 0}
    else
      {:left, &MapSet.put/2, 1}
    end
    {new_node, new_direction} = move(turn, n, direction)
    new_state = %{state | node: new_node, direction: new_direction, infections: op.(infections, n), infections_count: inf_count + infections_increment}
    burst(new_state, count + 1)
  end

  def current_node_infected?(%State{node: n, infections: infections}), do: infected?(infections, n)
  def infected?(infections, node), do: MapSet.member?(infections, node)

  def move(:left, {x, y}, :north), do: {{x-1, y}, :west}
  def move(:right, {x, y}, :north), do: {{x+1, y}, :east}
  def move(:left, {x, y}, :south), do: {{x+1, y}, :east}
  def move(:right, {x, y}, :south), do: {{x-1, y}, :west}
  def move(:left, {x, y}, :west), do: {{x, y-1}, :south}
  def move(:right, {x, y}, :west), do: {{x, y+1}, :north}
  def move(:left, {x, y}, :east), do: {{x, y+1}, :north}
  def move(:right, {x, y}, :east), do: {{x, y-1}, :south}
end
