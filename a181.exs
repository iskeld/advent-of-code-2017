defmodule Advent do
  defmodule State do
    defstruct [:registers, :sound]
  end

  def solve(input) do
    commands = parse(input)
    state = process({[], commands}, %State{registers: %{}})
    IO.puts state.sound
  end

  def parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def unwrap(list) when is_list(list), do: Enum.map(list, &unwrap/1)
  def unwrap(value = <<45, _x :: binary>>), do: String.to_integer(value)
  def unwrap(value = <<a, _x :: binary>>) when a < 48 or a > 57, do: value
  def unwrap(value), do: String.to_integer(value)

  def parse_line(input) when is_binary(input) do
    [op | args] = String.split(input)
    case {op, unwrap(args)} do
      {"snd", [x]} -> {:snd, x}
      {"rcv", [x]} -> {:rcv, x}
      {"set", [x, y]} -> {:set, x, y}
      {"add", [x, y]} -> {:add, x, y}
      {"mul", [x, y]} -> {:mul, x, y}
      {"mod", [x, y]} -> {:mod, x, y}
      {"jgz", [x, y]} -> {:jgz, x, y}
    end
  end

  def process({history, current = [command | tail]}, state) do
    case exec(command, state) do
      {:move, 1, new_state} ->
        process({[command | history], tail}, new_state)
      {:move, offset, new_state} ->
        commands = move(offset, {history, current})
        process(commands, new_state)
      {:halt, state} ->
        state
    end
  end

  def move(0, lists), do: lists
  def move(offset, {[prev | tail], current}) when offset < 0, do: move(offset + 1, {tail, [prev | current]})
  def move(offset, {history, [head | current]}) when offset > 0, do: move(offset - 1, {[head | history], current})

  def exec({:snd, x}, state) do
    sound_played = value_of(x, state)
    {:move, 1, %{state | sound: sound_played}}
  end

  def exec({:rcv, x}, state) do
    if value_of(x, state) != 0 do
      {:halt, state}
    else
      {:move, 1, state}
    end
  end

  def exec({:set, x, y}, state) do
    y_value = value_of(y, state)
    new_state = update_state(state, x, fn _x -> y_value end)
    {:move, 1, new_state}
  end

  def exec({:add, x, y}, state) do
    y_value = value_of(y, state)
    new_state = update_state(state, x, &(&1 + y_value))
    {:move, 1, new_state}
  end

  def exec({:mul, x, y}, state) do
    y_value = value_of(y, state)
    new_state = update_state(state, x, &(&1 * y_value))
    {:move, 1, new_state}
  end

  def exec({:mod, x, y}, state) do
    y_value = value_of(y, state)
    new_state = update_state(state, x, &rem(&1, y_value))
    {:move, 1, new_state}
  end

  def exec({:jgz, x, y}, state) do
    if value_of(x, state) > 0 do
      {:move, value_of(y, state), state}
    else
      {:move, 1, state}
    end
  end

  def update_state(state = %State{registers: registers}, x, updater) do
    current_value = registers[x] || 0
    new_value = updater.(current_value)
    %{state | registers: Map.put(registers, x, new_value)}
  end

  def value_of(x, %State{registers: registers}), do: value_of(x, registers)
  def value_of(x, _registers) when is_integer(x), do: x
  def value_of(x, registers), do: registers[x]
end
