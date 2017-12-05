defmodule Advent do
  def solve(input) when is_binary(input) do
    input
    |> String.split(["\n", "\r"], trim: true) 
    |> Enum.map(fn (line) -> String.split(line) |> Enum.map(&String.to_integer/1) end)
    |> Enum.map(&division/1)
    |> Enum.sum
  end

  defp division(list) when is_list(list) do
    {dividend, divisor} = line_div(Enum.sort(list))
    round(dividend / divisor)
  end

  defp line_div([head | tail]) do
    match = Enum.find(tail, nil, fn(x) -> rem(x, head) == 0 end)
    case match do
      nil -> line_div(tail)
      _ -> {match, head}
    end
  end
end
