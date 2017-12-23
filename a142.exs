defmodule Advent do
  use Bitwise, include_operators: false

  @matrix_size 128
  @list_size 256
  @suffix [17, 31, 73, 47, 23]

  def solve(input) do
    build_matrix_map(input) |> walk_matrix(0, 0)
  end

  def walk_matrix(_matrix, @matrix_size, count), do: count
  def walk_matrix(matrix, row_index, count) do
    {new_matrix, new_count} = walk_row(matrix, matrix[row_index], row_index, 0, count)
    walk_matrix(new_matrix, row_index + 1, new_count)
  end

  def walk_row(matrix, _row, _row_index, column_index, count) when column_index >= @matrix_size, do: {matrix, count}
  def walk_row(matrix, row, row_index, column_index, count) do
    if row[column_index] == 1 do
      new_matrix = purge_group(matrix, row_index, column_index)
      walk_row(new_matrix, new_matrix[row_index], row_index, column_index + 2, count + 1)
    else
      walk_row(matrix, row, row_index, column_index + 1, count)
    end
  end

  def purge_group(matrix, row_index, column_index) do
    Map.put(matrix, row_index, Map.put(matrix[row_index], column_index, nil))
    |> purge_right(row_index, column_index)
    |> purge_down(row_index, column_index)
    |> purge_up(row_index, column_index)
    |> purge_left(row_index, column_index)
  end

  def purge_up(matrix, row_index, column_index) do
    if matrix[row_index-1][column_index] == 1 do
      purge_group(matrix, row_index-1, column_index)
    else
      matrix
    end
  end

  def purge_down(matrix, row_index, column_index) do
    if matrix[row_index+1][column_index] == 1 do
      purge_group(matrix, row_index+1, column_index)
    else
      matrix
    end
  end

  def purge_left(matrix, row_index, column_index) do
    if matrix[row_index][column_index-1] == 1 do
      purge_group(matrix, row_index, column_index-1)
    else
      matrix
    end
  end

  def purge_right(matrix, row_index, column_index) do
    if matrix[row_index][column_index+1] == 1 do
      purge_group(matrix, row_index, column_index+1)
    else
      matrix
    end
  end

  def build_matrix_map(input) do
    inputs(input)
    |> Enum.with_index()
    |> Map.new(fn {x, index} -> {index, to_binary_map(hash(x))} end)
  end

  def to_binary_map(hash) do
    Integer.parse(hash, 16) 
    |> elem(0) 
    |> Integer.to_string(2) 
    |> String.pad_leading(128, "0")
    |> String.to_charlist()
    |> Enum.with_index()
    |> Map.new(fn {x, index} -> {index, x - ?0} end)
  end

  def inputs(src), do: Enum.map(0..127, &("#{src}-#{&1}"))

  def hash(input) when is_binary(input) do
    lengths = get_lengths(input)
    {list, index, _skip} = Enum.reduce(1..64, {get_list(), 0, 0}, fn (_x, {list, index, skip}) -> move_by_len(list, index, lengths, skip) end)
    list = extract_result(list, index)
    dense_hash(list) |> Enum.map(&Integer.to_string(&1, 16) |> String.pad_leading(2, "0")) |> Enum.join() |> String.downcase()
  end

  def get_list(), do: 0..@list_size-1 

  def get_lengths(input), do: String.to_charlist(input) ++ @suffix

  def dense_hash(sparse) when is_list(sparse), do: Enum.chunk_every(sparse, 16) |> Enum.map(&dense_segment/1)

  def dense_segment(elements) when is_list(elements), do: Enum.reduce(elements, &Bitwise.bxor/2)

  def extract_result(list, current_index) do
    {rear, front} = Enum.split(list, -current_index)
    front ++ rear
  end

  def move_by_len(list, current_index, [], skip) do
     {list, current_index, skip}
  end
  def move_by_len(list, current_index, [len | lengths], skip) do
    {to_rev, rest} = Enum.split(list, len)
    new_list = rest ++ Enum.reverse(to_rev)
    move_by_skip(new_list, increase_index(current_index, len), lengths, skip)
  end

  def move_by_skip(list, current_index, lengths, skip) do
    {rear, front} = Enum.split(list, rem(skip, @list_size))
    move_by_len(front ++ rear, increase_index(current_index, skip), lengths, skip + 1)
  end

  def increase_index(index, inc), do: rem(index + inc, @list_size)
end
