defmodule Advent do
  use Bitwise

  @factor_a 16807
  @factor_b 48271
  @div 2147483647
  @b 65535

  def next(prev, factor), do: rem(prev * factor, @div)
  def generate({a, b}), do: {next(a, @factor_a), next(b, @factor_b)}
  def match({a, b}) do
    band(a, @b) == band(b, @b)
  end

  def solve(a, b, count) do
    prev = {a, b}
    start = if match(prev), do: 1, else: 0
    run(prev, start, count)
  end

  def run(_, matches, 0), do: matches
  def run(prev, matches, counter) do
    curr = generate(prev)
    if match(curr) do
      run(curr, matches + 1, counter - 1)
    else
      run(curr, matches, counter - 1)
    end
  end
end
