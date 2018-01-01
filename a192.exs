defmodule Advent do
  defmodule State do
    defstruct [:row, :col, :dir, :letters, :steps]
  end

  def solve(input) do
    {maze, start_col} = parse(input) 
    walk(maze, %State{row: 1, col: start_col, dir: :south, letters: [], steps: 1})
  end

  def parse(input) do
    maze = String.split(input, "\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> to_indexes_map()

    {maze, find_entry(maze)}
  end

  def find_entry(maze) when is_map(maze) do
    maze[0] |> Enum.find(fn {_idx, x} -> x == ?| end) |> elem(0)
  end

  def parse_line(input) when is_binary(input) do
    input
    |> String.to_charlist()
    |> to_indexes_map()
  end

  def walk(maze, state = %State{row: row, col: col, letters: letters, steps: steps}) do
    state = %{state | steps: steps + 1}
    case maze[row][col] do
      ?\s -> steps
      ?+ -> walk(maze, crossroad(maze, state))
      letter when letter >= ?A and letter <= ?Z -> walk(maze, go_on(%{state | letters: [letter | letters]}))
      nil -> :error
      _ -> walk(maze, go_on(state))
    end
  end

  def crossroad(maze, state = %State{row: row, col: col, dir: dir}) do
    if dir == :north || dir == :south do
      {dir, col_offest} = if maze[row][col-1] == ?-, do: {:west, -1}, else: {:east, 1}
      %{state | col: col + col_offest, dir: dir}
    else
      {dir, row_offset} = if maze[row-1][col] == ?|, do: {:north, -1}, else: {:south, 1}
      %{state | row: row + row_offset, dir: dir}
    end
  end

  def go_on(state = %State{row: row, dir: :north}), do: %{state | row: row - 1}
  def go_on(state = %State{row: row, dir: :south}), do: %{state | row: row + 1}
  def go_on(state = %State{col: col, dir: :east}), do: %{state | col: col + 1}
  def go_on(state = %State{col: col, dir: :west}), do: %{state | col: col - 1}

  def to_indexes_map(list), do: Enum.with_index(list) |> indexed_to_map()

  def indexed_to_map(list) when is_list(list) do
    Map.new(list, fn {x, idx} -> {idx, x} end)
  end
end
