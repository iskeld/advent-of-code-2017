defmodule Advent do
  defmodule Particle do
    defstruct [:index, :pos, :vel, :acc]
  end

  def solve(input) do
    parse(input) |> move_and_clean(90000) |> Enum.count()
  end

  def parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(&parse_line/1)
    |> Map.new(fn (p = %Particle{index: index}) -> {index, p} end)
  end

  def move_and_clean(particles, 0), do: particles
  def move_and_clean(particles, counter) do
    particles
    |> move_all()
    |> clear_collisions()
    |> move_and_clean(counter - 1)
  end

  def move_all(particles) when is_map(particles) do
    particles
    |> Enum.map(fn {index, p} -> {index, move(p)} end)
    |> Map.new()
  end

  def clear_collisions(particles) when is_map(particles) do
    {_, to_drop} = Map.values(particles)
    |> Enum.reduce({Map.new(), []}, fn (x, acc) -> collide(acc, x) end) 

    Enum.reduce(to_drop, particles, fn (index, acc) -> Map.delete(acc, index) end)
  end

  def collide({positions, to_drop}, %Particle{index: index, pos: pos}) do
    {prev, positions} = Map.get_and_update(positions, pos, fn current -> {current, index} end)
    to_drop = if prev != nil, do: [index | [prev | to_drop]], else: to_drop
    {positions, to_drop}
  end

  def parse_line({input, index}) when is_binary(input) do
    [p, v, a] =
      Regex.run(~r"p=<(.*)>, v=<(.*)>, a=<(.*)>", input)
      |> Enum.drop(1)
      |> Enum.map(&parse_unit/1)
    %Particle{index: index, pos: p, vel: v, acc: a}
  end

  def parse_unit(input) do
    String.split(input, ",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
  end

  def move(p = %Particle{pos: pos, vel: vel, acc: acc}) do
    new_vel = add(vel, acc)
    new_pos = add(pos, new_vel)
    %{p | vel: new_vel, pos: new_pos}
  end

  def add({x0, y0, z0}, {x1, y1, z1}), do: {x0 + x1, y0 + y1, z0 + z1}
end
