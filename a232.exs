defmodule Advent do
  @b 109300
  @c 126300

  def solve(), do: iterate(@b, 0)

  def iterate(@c, h), do: h
  def iterate(b, h) do
    IO.puts b
    h = h + one_if_not_prime(b)
    iterate(b+17, h) 

    #if b == @c, do: h, else: iterate(b + 17, h)
  end

  def one_if_not_prime(x), do: if is_not_prime(x), do: 1, else: 0
  def is_not_prime(x), do: (2..x-1 |> Enum.any?(fn a -> rem(x, a) == 0 end))
end
