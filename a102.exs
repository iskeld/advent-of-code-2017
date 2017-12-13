defmodule Advent do
  use Bitwise, include_operators: false

  @list_size 256
  @suffix [17, 31, 73, 47, 23]

  def solve(input) when is_binary(input) do
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
