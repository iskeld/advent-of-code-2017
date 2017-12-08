defmodule Advent do
  def solve(input) when is_binary(input) do
    items_with_children = input
    |> String.split("\n", trim: true) 
    |> Enum.map(&parse_line/1)
    |> Enum.filter(&has_children?/1)

    {root, _, _} = Enum.find(items_with_children, nil, 
              fn ({name, _weight, _children}) -> has_no_parent?(name, items_with_children) end)
    root
  end

  def parse_line(line) when is_binary(line) do
    regex = ~r/(?<name>\w+)\s+\((?<weight>\d+)\)( -> (?<children>.+))*/
    %{"children" => children, "name" => name, "weight" => weight} = Regex.named_captures(regex, line)
    case children do
      "" -> 
        {name, String.to_integer(weight)}
      _ -> 
        child_list = String.split(children, [",", " "], trim: true) |> MapSet.new()
        {name, String.to_integer(weight), child_list}
    end
  end

  defp has_no_parent?(name, list), do: Enum.all?(list, &(!is_child(name, &1)))

  defp is_child(name, {_name, _weight, children}), do: MapSet.member?(children, name)

  defp has_children?({_name, _weight, _children}), do: true
  defp has_children?({_name, _weight}), do: false
end
