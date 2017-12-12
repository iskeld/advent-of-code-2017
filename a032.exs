defmodule Advent do
  def simple_square(1), do: {[1], [1], [1], [1]}
  def simple_square(size) do
    step = size - 1
    first_edge = round(:math.pow(size - 2, 2)) + step
    last_edge = first_edge + step*3
    {
      [last_edge | Enum.to_list(first_edge - step + 1..first_edge)],
      Enum.to_list(first_edge..first_edge + step),
      Enum.to_list(first_edge+step..first_edge + step*2),
      Enum.to_list(first_edge+step*2..first_edge + step*3),
    }
  end

  def solve(input) do
    values = sum() |> Enum.find(nil, fn(x) ->
      Enum.find(x, nil, fn({_index, val}) -> val > input end)
    end)

    if values != nil do
      {_index, res} = Enum.find(values, nil, fn({_index, val}) -> val > input end)
      res
    end
  end

  def sum() do
    Stream.unfold({3, %{1 => 1}}, &squares/1)
  end

  def squares({size, map}) do
    square_points = square(size)
    indexes = square_points |> Enum.map(fn (%{value: value}) -> value end)
    result = square_points |> Enum.reduce(map, fn(x, acc) -> sum_neighbours(x, acc) end)
    element = Map.take(result, indexes) |> Map.to_list()
    {element, {size + 2, result}}
  end

  def sum_neighbours(%{value: value, neighbours: neighbours}, map) do
    sum = fn () -> neighbours |> Enum.map(fn (x) -> Map.get(map, x) end) |> Enum.sum() end
    Map.put_new_lazy(map, value, sum)
  end

  def square(1), do: point(1, [])
  def square(size) do
    step = size - 1
    prev_edge = round(:math.pow(size - 2, 2))
    first_item = prev_edge + 1
    first_edge = prev_edge + step
    last_edge = first_edge + step*3
    first_mid = round(prev_edge + step/2)
    middles = (0..3) |> Enum.map(fn(x) -> first_mid + step*x end) |> List.to_tuple()
    inner_square = simple_square(size - 2)
    inner_middle_pos = round((size - 3) / 2)
    for n <- first_item..last_edge,
      side = round(4 - :math.floor((last_edge - n)/step)) - 1,
      len_from_mid = n - elem(middles, side),
      inner_neighbours = get_inner_neighbours(len_from_mid, elem(inner_square, side), inner_middle_pos) do
      case n do
        ^first_item -> point(n, inner_neighbours)
        ^last_edge -> point(n, [n-1, first_item] ++ inner_neighbours)
        _ ->
          case rem(n - first_edge, step) do
            0 -> point(n, [n-1] ++ inner_neighbours)
            1 -> point(n, [n-1, n-2] ++ inner_neighbours)
              if n == last_edge - 1 do
                  point(n, [n-1, n-2, first_item] ++ inner_neighbours)
              else
                  point(n, [n-1, n-2] ++ inner_neighbours)
              end
            _ -> 
              if n == last_edge - 1 do
                  point(n, [n-1, first_item] ++ inner_neighbours)
              else
                  point(n, [n-1] ++ inner_neighbours)
              end
          end
      end
    end
  end

  def get_inner_neighbours(len_from_mid, inner_side, inner_middle_pos) do
    from = max(0, len_from_mid + inner_middle_pos - 1)
    to = min(length(inner_side) - 1, len_from_mid + inner_middle_pos + 1)
    Enum.slice(inner_side, from..to)
  end

  def point(value, neighbours) do
    %{value: value, neighbours: neighbours}
  end
end
