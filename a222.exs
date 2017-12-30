defmodule Advent do
  defmodule State do
    defstruct [:node, :direction, :nodes, :infections_count]
  end

  def solve(input) do
    state = %State{node: {0,0}, direction: :north, nodes: parse(input), infections_count: 0}
    burst(state, 0)
  end

  def parse(input) do
    lines = String.split(input, "\n", trim: true)
    size = length(lines)
    max = div(size - 1, 2)
    {infected, _} = Enum.reduce(lines, {Map.new(), max}, fn (line, {infected, y}) -> {parse_line(line, {-max, y}, infected), y - 1} end)
    infected
  end

  def parse_line(<<>>, _x, infected), do: infected
  def parse_line(<<c, rest :: binary>>, loc = {x, y}, infected) do
    infected = case c do
      ?# -> Map.put(infected, loc, :infected)
      _ -> infected
    end
    parse_line(rest, {x + 1, y}, infected)
  end

  def burst(state, count) when count >= 10000000, do: state
  def burst(state = %State{node: n, direction: direction, nodes: nodes, infections_count: inf_count}, count) do
    {new_state, moving, infections_increment} = case current_node_state(state) do
      :clean -> {:weakened, :left, 0}
      :weakened -> {:infected, :same, 1}
      :infected -> {:flagged, :right, 0}
      :flagged -> {:clean, :reverse, 0}
    end

    new_map = case new_state do
      :clean -> Map.delete(nodes, n)
      _ -> Map.put(nodes, n, new_state)
    end

    {new_node, new_direction} = move(moving, n, direction)
    new_state = %{state | node: new_node, direction: new_direction, nodes: new_map, infections_count: inf_count + infections_increment}
    burst(new_state, count + 1)
  end

  def current_node_state(%State{node: n, nodes: nodes}) do
    Map.get(nodes, n, :clean)
  end

  def move(:same, {x, y}, :north), do: {{x, y+1}, :north}
  def move(:reverse, {x, y}, :north), do: {{x, y-1}, :south}
  def move(:left, {x, y}, :north), do: {{x-1, y}, :west}
  def move(:right, {x, y}, :north), do: {{x+1, y}, :east}

  def move(:same, {x, y}, :south), do: {{x, y-1}, :south}
  def move(:reverse, {x, y}, :south), do: {{x, y+1}, :north}
  def move(:left, {x, y}, :south), do: {{x+1, y}, :east}
  def move(:right, {x, y}, :south), do: {{x-1, y}, :west}

  def move(:same, {x, y}, :west), do: {{x-1, y}, :west}
  def move(:reverse, {x, y}, :west), do: {{x+1, y}, :east}
  def move(:left, {x, y}, :west), do: {{x, y-1}, :south}
  def move(:right, {x, y}, :west), do: {{x, y+1}, :north}

  def move(:same, {x, y}, :east), do: {{x+1, y}, :east}
  def move(:reverse, {x, y}, :east), do: {{x-1, y}, :west}
  def move(:left, {x, y}, :east), do: {{x, y+1}, :north}
  def move(:right, {x, y}, :east), do: {{x, y-1}, :south}
end
