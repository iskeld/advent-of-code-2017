defmodule Advent do
  def solve(code) when is_binary(code) do
    String.graphemes(code) |> Enum.map(&(String.to_integer(&1))) |> captcha
  end

  def captcha([]), do: 0
  def captcha([_elem]), do: 0
  def captcha([head | tail]), do: captcha_sum(0, head, head, tail)

  defp captcha_sum(sum, first, current, []) do
    (current == first) && (sum + current) || sum
  end
  defp captcha_sum(sum, first, current, [head | tail]) do
    new_sum = (current == head) && (sum + current) || sum
    captcha_sum(new_sum, first, head, tail)
  end
end
