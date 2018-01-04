defmodule Advent do
  @programs_count 16

  def solve(input) do
    moves = input |> parse
    start = dance(init_map(), moves)

    # 48 is the number of cycles until the same seq is generated - found out with check_dance
    # TODO: find better way
    count = rem(1000000000, 48) - 1
    dance(start, moves, count) |> dump()
  end

  def undump(str) do
    str
    |> String.to_charlist()
    |> Enum.with_index()
    |> Enum.map(fn {chr, index} -> {String.to_atom(to_string([chr])), index} end)
    |> Map.new()
  end

  def dump(map) do
    map |> Enum.sort(fn ({_, i1}, {_, i2}) -> i1 < i2 end) |> Enum.map(fn {x, _} -> to_string(x) end) |> Enum.join()
  end

  def init_map() do
    0..@programs_count-1 |> Enum.map(fn x -> {to_string([x + 97]) |> String.to_atom(), x} end) |> Map.new()
  end

  def dance(map, _, 0), do: map
  def dance(map, moves, counter) do
    dance(dance(map, moves), moves, counter - 1)
  end

  def check_dance(start, map, moves, counter) do
    if rem(counter, 1000) == 0, do: IO.puts counter
    new_map = dance(map, moves)
    if (start == new_map) do
      IO.puts "FOOOO #{counter}"
    end

    check_dance(start, new_map, moves, counter - 1)
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
