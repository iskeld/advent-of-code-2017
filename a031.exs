defmodule Advent do
  def solve(input) when is_integer(input) do
    side = side_len(input)
    tmp_side = side - 1
    len_to_center = tmp_side / 2
    last_mid = :math.pow(side, 2) - len_to_center
    middles = [last_mid - 3*tmp_side, last_mid - 2*tmp_side, last_mid - tmp_side, last_mid]
    min_distance = middles |> Enum.map(&abs(input - &1)) |> Enum.min()
    len_to_center + min_distance
  end

  defp side_len(input) do
    case input |> :math.sqrt() |> :math.ceil() |> round() do
      x when rem(x, 2) == 0 -> x + 1
      x -> x
    end
  end
end
