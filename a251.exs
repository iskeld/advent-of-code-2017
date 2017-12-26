defmodule Advent do
  defmodule Command do
    defstruct [:value, :direction, :next_state]
  end

  defmodule State do
    defstruct [:name, :ifzero, :ifone]
  end

  def solve(input) do
    {initial_state, max, states} = parse(input)
    {left, right} = process({initial_state, [], [0]}, states, max, 0)
    Enum.count(left ++ right, &(&1 == 1))
  end

  def process({_, left, right}, _, max, counter) when counter >= max, do: {left, right}
  def process({state_name, left, right = [current | _tail]}, states, max, counter) do
    states[state_name]
    |> get_cmd(current)
    |> run_cmd(left, right)
    |> process(states, max, counter + 1)
  end

  def get_cmd(%State{ifzero: ifzero}, 0), do: ifzero
  def get_cmd(%State{ifone: ifone}, 1), do: ifone

  def run_cmd(%Command{next_state: state, value: value, direction: direction}, left, [_current | right]) do
    list = {left, [value | right]}
    {new_left, new_right} = if direction == :left, do: move_left(list), else: move_right(list)
    {state, new_left, new_right}
  end

  def move_left({[], right}), do: {[], [0 | right]}
  def move_left({[head | left], right}), do: {left, [head | right]}
  def move_right({left, [current | []]}), do: {[current | left], [0]} 
  def move_right({left, [current | right]}), do: {[current | left], right} 

  def parse(input) do
    [initial_state | [checksum | states]] = String.split(input, "\n", trim: true)
    states_map = Map.new(parse_states(states), fn (state = %State{name: name}) -> {name, state} end)
    {parse_initial_state(initial_state), parse_checksum_count(checksum), states_map}
  end

  def parse_states(commands) do
    Enum.chunk_every(commands, 9)
    |> Enum.map(&parse_state/1)
  end

  def parse_state(state) do
    ["In state " <> name | branches] = state
    state_name = String.at(name, 0)
    [ifzero, ifone] = Enum.chunk_every(branches, 4)
    %State{name: state_name, ifzero: parse_branch(ifzero, 0), ifone: parse_branch(ifone, 1)}
  end

  def parse_branch(commands, value) do
    commands = Enum.map(commands, &String.trim/1)
    header = "If the current value is #{value}:"
    [^header,
     "- Write the value " <> value_to_write_string,
     "- Move one slot to the " <> direction_string,
     "- Continue with state " <> next_state_string] = commands
    direction = if direction_string =~ "left", do: :left, else: :right
    value = String.to_integer(String.trim(value_to_write_string, "."))
    %Command{next_state: get_state_name(next_state_string), 
      direction: direction, value: value}
  end

  defp get_state_name(name), do: String.at(name, 0)

  def parse_initial_state("Begin in state " <> state), do: get_state_name(state)

  def parse_checksum_count(line) do
    [_, result] = Regex.run(~r"Perform a diagnostic checksum after (\d+) steps", line)
    String.to_integer(result)
  end
end
