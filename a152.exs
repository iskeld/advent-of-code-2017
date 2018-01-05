defmodule Advent do
  use Bitwise

  @factor_a 16807
  @factor_b 48271
  @div 2147483647
  @b 65535

  def solve(start_a, start_b, iterations) do
    streams(start_a, start_b)
    |> Stream.take(iterations)
    |> Enum.count(&(&1))
  end

  def streams(start_a, start_b) do
    Stream.zip(stream_a(start_a), stream_b(start_b))
    |> Stream.map(&match/1)
  end

  def stream_a(start), do: get_stream(start, @factor_a, 4)
  def stream_b(start), do: get_stream(start, @factor_b, 8)

  def get_stream(start, factor, multiplier) do
    next(start, factor)
    |> Stream.iterate(&next(&1, factor))
    |> Stream.filter(fn x -> rem(x, multiplier) == 0 end)
  end

  def next(prev, factor), do: rem(prev * factor, @div)

  def match({a, b}), do: band(a, @b) == band(b, @b)
end
