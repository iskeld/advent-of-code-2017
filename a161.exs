defmodule Advent do
  @programs_count 16

  def solve(input) do
    moves = input |> parse
    dance(init_map(), moves) |> dump()
  end

  def dump(map) do
    map |> Enum.sort(fn ({_, i1}, {_, i2}) -> i1 < i2 end) |> Enum.map(fn {x, _} -> to_string(x) end) |> Enum.join()
  end

  def init_map() do
    0..@programs_count-1 |> Enum.map(fn x -> {to_string([x + 97]) |> String.to_atom(), x} end) |> Map.new()
  end

  def dance(map, moves) do
    Enum.reduce(moves, map, fn (cmd, acc) -> exec(acc, cmd) end)
  end

  def parse(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(&parse_cmd/1)
  end

  def parse_cmd(cmd) do
    case cmd do
      <<"s", x :: binary>> -> {:spin, String.to_integer(x)}
      <<"x", x :: binary>> -> 
        [a, b] = parse_args(x)
        {:ex, String.to_integer(a), String.to_integer(b)}
      <<"p", x :: binary>> ->
        [a, b] = parse_args(x)
        {:partner, String.to_existing_atom(a), String.to_existing_atom(b)}
    end
  end

  def parse_args(str), do: String.split(str, "/")

  def exec(map, {:spin, offset}) do
    map |> Enum.map(fn {p, index} -> {p, move_index(index, offset)} end) |> Map.new()
  end

  def exec(map, {:partner, a, b}), do: swap(map, a, b)

  def exec(map, {:ex, idx_a, idx_b}) do
    [{a, _}, {b, _}] = map |> Enum.filter(fn {_, index} -> index == idx_a || index == idx_b end)
    swap(map, a, b)
  end

  def swap(map, a, b) do
    Map.merge(map, Map.new([{a, map[b]}, {b, map[a]}]))
  end

  def move_index(index, offset), do: rem(index + offset, @programs_count)
end
