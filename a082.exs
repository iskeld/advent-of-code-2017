defmodule Advent do
  def solve(input) when is_binary(input) do
    {commands, registry} = input
    |> String.split("\n", trim: true)
    |> Enum.map_reduce(%{}, &parse_line/2)

    {max, _} = Enum.reduce(commands, {0, registry}, &exec/2)
    max
  end

  def exec({_, _, _, register, op, value} = instruction, {max, registry}) when is_map(registry) do
    if is_true(instruction, registry) do
      Map.get_and_update!(registry, register, fn x ->
        new_val = op.(x, value)
        {max(max, new_val), new_val}
      end)
    else
      {max, registry}
    end
  end

  def is_true({cond_reg, comparision, value, _, _, _}, registry) do
    comparision.(Map.fetch!(registry, cond_reg), value)
  end

  def parse_line(line, registry) when is_binary(line), do: parse_line(String.split(line), registry)
  def parse_line([reg, cmd, val, "if", cond_reg, comparision, cond_val], registry) when is_map(registry) do
    result_cmd = case cmd do
      "inc" -> &+/2
      "dec" -> &-/2
    end

    result_comp = case comparision do
      ">" -> &(>/2)
      ">=" -> &(>=/2)
      "<" -> &(</2)
      "<=" -> &(<=/2)
      "==" -> &(==/2)
      "!=" -> &(!=/2)
    end

    new_registry = Map.merge(registry, %{reg => 0, cond_reg => 0})
    {{cond_reg, result_comp, String.to_integer(cond_val), reg, result_cmd, String.to_integer(val)}, new_registry}
  end
end
