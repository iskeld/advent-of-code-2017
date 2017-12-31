defmodule Advent do
  @initial_pattern [0,1,0,0,0,1,1,1,1]

  def solve(input, iterations) do
    rules = parse(input)
    break(@initial_pattern, rules, iterations)
    #    |> count_on()
  end

  def count_on(list), do: Enum.count(list, fn x -> x == 1 end)

  def initial_pattern(), do: @initial_pattern

  def parse(input) do
    input 
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.group_by(fn {size, _src, _dst} -> size end, fn {_, src, dst} -> {src, dst} end)
    |> Enum.map(fn {size, data} -> {size, Map.new(data)} end)
    |> Map.new()
  end

  def parse_line(line) do
    [src, dst] = line 
                 |> String.replace("/", "") 
                 |> String.replace(".", "0") 
                 |> String.replace("#", "1") 
                 |> String.split(" => ")
    {round(:math.sqrt(String.length(src))), parse_pixels(src), parse_pixels(dst)}
  end

  def parse_pixels(str), do: String.to_charlist(str) |> Enum.map(&(&1 - ?0))

  def to_pixels(list) do
    Enum.map(list, fn 1 -> "#"
                      0 -> "."
    end)
  end
  def pixel_variations(list) do
    v = variations(to_pixels(list))
    size = list |> length() |> :math.sqrt() |> round() 
    Enum.map(v, fn list -> Enum.chunk_every(list, size) |> Enum.intersperse("/") end)
    |> Enum.map(fn x -> List.flatten(x) |> Enum.join() end)
  end

  def break(list, _rules, 0), do: list
  def break(list, rules, counter) do
    size = list |> length() |> :math.sqrt() |> round() 

    new_list = if rem(size, 2) == 0 do
      chunk(list, size, 2, rules[2])
    else
      chunk(list, size, 3, rules[3])
    end
    break(new_list, rules, counter - 1)
  end

  def chunk(list, size, slice, rules) do
    list
    |> Enum.with_index()
    |> Enum.group_by(fn {_x, index} -> Advent.get_group(index, size, slice) end, fn {x, _index} -> x end)
    |> Enum.map(fn ({header, list}) -> {header, enhance(list, rules)} end)
    |> Enum.group_by(fn {{col, _row}, _list} -> col end, fn {{_col, _row}, list} -> list end)
    |> join()
  end

  def join(list) do
    size = Map.values(list) |> Enum.at(0) |> Enum.at(0) |> length() |> :math.sqrt() |> round()
    size = if rem(size, 2) == 0, do: 2, else: 3
    Enum.reduce(list, [], fn ({_, x}, acc) -> acc ++ join_group(x, size) end)
  end

  def join_group(lists, 2) do
    Enum.flat_map(lists, fn x -> Enum.take(x, 2) end) ++ Enum.flat_map(lists, fn x -> Enum.drop(x, 2) end)
  end

  def join_group(lists, 3) do
    Enum.flat_map(lists, fn x -> Enum.take(x, 3) end) ++ Enum.flat_map(lists, fn x -> Enum.slice(x, 3, 3) end) ++ Enum.flat_map(lists, fn x -> Enum.drop(x, 6) end)
  end

  def get_group(index, size, slice) do
    row_index = rem(index, size)
    col_index = div(index, size)
    row_group = div(row_index, slice)
    col_group = div(col_index, slice)
    {col_group, row_group}
  end

  def enhance(list, rules) do
    list
    |> variations()
    |> Enum.find_value(fn (x) -> rules[x] end)
  end

  def variations(list) do
    list
    |> rotations()
    |> Enum.flat_map(fn l -> flips(l) end)
    |> MapSet.new()
    |> Enum.to_list()
  end

  def rotations(list = [a0, a1, a2, a3, a4, a5, a6, a7, a8]) do
    [list,
     [a2, a5, a8, a1, a4, a7, a0, a3, a6], # 90*
     Enum.reverse(list), # 180*
     [a6, a3, a0, a7, a4, a1, a8, a5, a2], # 270*
    ]
  end

  def rotations(list = [a0, a1, a2, a3]) do
    [list,
     [a1, a3, a0, a2], # 90*
     Enum.reverse(list), # 180*
     [a2, a0, a3, a1], # 270*
    ]
  end

  def flips(list = [a0, a1, a2, a3, a4, a5, a6, a7, a8]) do
     [list, [a2, a1, a0, a5, a4, a3, a8, a7, a6], # flip hor
     [a6, a7, a8, a3, a4, a5, a0, a1, a2]] # flip ver
  end

  def flips(list = [a0, a1, a2, a3]) do
     [list, [a1, a0, a3, a2], # flip hor
     [a2, a3, a0, a1]] # flip ver
  end

end

