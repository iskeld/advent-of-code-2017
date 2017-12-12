defmodule Advent do
  def solve(input) when is_binary(input) do
    input
    |> String.split(["\n", "\r"], trim: true) 
    |> Enum.map(fn (line) -> String.split(line) |> Enum.map(&String.to_integer/1) end)
    |> Enum.map(&diff/1)
    |> Enum.sum
  end

  defp diff(list) when is_list(list) do
    {min, max} = minmax(list)
    max - min
  end

  defp minmax([head | tail]), do: minmax(tail, {head, head})
  defp minmax([], {min, max}), do: {min, max}
  defp minmax([head | tail], {min, max}), do: minmax(tail, {min(min, head), max(max, head)})
end
