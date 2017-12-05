defmodule Advent do
  def solve(code) when is_binary(code) do
    String.graphemes(code) 
    |> Enum.with_index()
    |> Enum.map(fn ({item, index}) -> {index, String.to_integer(item)} end)
    |> Map.new()
    |> captcha()
  end

  def captcha(map) when is_map(map) do
    Enum.reduce(map, 0, fn(tuple, sum) -> match_element(tuple, sum, map) end)
  end

  defp match_element({index, element}, sum, map) do
    size = Enum.count(map)
    step = trunc(size / 2)
    pair_index = rem(index + step, size)
    (element == map[pair_index]) && (sum + element) || sum
  end
end
