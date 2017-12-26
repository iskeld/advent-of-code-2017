defmodule Advent do
  def solve(input) do
    components = parse(input)
    results = step(0, components, [], 0)
    Enum.max(results)
  end

  def parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(input) when is_binary(input) do
    [one, two] = String.split(input, "/")
    {String.to_integer(one), String.to_integer(two)}
  end

  def get_matches(port, list) do
    Stream.unfold(0, fn drop_count ->
      {visited, to_search} = Enum.split(list, drop_count)
      case pop_with_index(to_search, fn x -> is_match(port, x) end) do
        {nil, _, _} -> nil
        {{port1, port2}, index, rest} ->
          match = if port1 == port, do: port2, else: port1
          {{match, visited ++ rest}, index + drop_count + 1}
      end
    end)
  end

  def pop_with_index(list, fun), do: pop_with_index(list, [], 0, fun)
  def pop_with_index([], visited, _index, _fun), do: {nil, nil, Enum.reverse(visited)}
  def pop_with_index([head | tail], visited, index, fun) do
    if fun.(head) do
      {head, index, Enum.reverse(visited) ++ tail}
    else
      pop_with_index(tail, [head | visited], index + 1, fun)
    end
  end

  def step(port, components, edges, strength) do
    current_strength = port + strength
    matches = get_matches(port, components)
    result = Enum.reduce(matches, {:empty, edges}, fn ({side_port, rest}, {_, acc}) ->
      {:ok, step(side_port, rest, acc, port + current_strength)}
    end)

    case result do
      {:empty, _} -> [current_strength | edges]
      {:ok, new_edges} -> new_edges
    end
  end

  def is_match(port, {a, b}), do: port == a or port == b
end
