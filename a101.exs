defmodule Advent do
  @list_size 256
  def solve(input) when is_binary(input) do
    lengths = String.split(input, ",") |> Enum.map(&String.to_integer/1)
    last_elem = @list_size - 1
    move_by_len(0..last_elem, 0, lengths, 0)
  end

  def move_by_len(list, current_index, [], skip) do
    {list, current_index}
    {rear, front} = Enum.split(list, -current_index)
    result = front ++ rear
    [a, b] = Enum.take(result, 2)
    {a * b, result, list, current_index}
  end
  def move_by_len(list, current_index, [len | lengths], skip) do
    {to_rev, rest} = Enum.split(list, len)
    new_list = rest ++ Enum.reverse(to_rev)
    move_by_skip(new_list, increase_index(current_index, len), lengths, skip)
  end

  def move_by_skip(list, current_index, lengths, skip) do
    {rear, front} = Enum.split(list, skip)
    move_by_len(front ++ rear, increase_index(current_index, skip), lengths, skip + 1)
  end

  def increase_index(index, inc) do
    rem(index + inc, @list_size)
  end
end
