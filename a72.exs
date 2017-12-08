defmodule Advent do
  def solve(input) when is_binary(input) do
    tree = build_tree(input)
    is_balanced(tree)
  end

  def build_tree(input) when is_binary(input) do
    input
    |> String.split("\n", trim: true) 
    |> Enum.map(&parse_line/1)
    |> build_tree()
  end
  def build_tree(items) when is_list(items) do
    root = find_root(items)
    map = Map.new(items, fn {name, weight, children} -> {name, {weight, children}} end)
    {tree, _map} = build_tree(root, map)
    tree
  end

  def build_tree(node_name, map) do
    {{weight, child_names}, map} = Map.pop(map, node_name)
    {children, map} = if child_names == :empty do
      {[], map}
    else
      Enum.map_reduce(child_names, map, &build_tree/2)
    end
    sum = Enum.reduce(children, weight, fn({_name, _weight, sum, _children}, acc) -> sum + acc end)
    {{node_name, weight, sum, children}, map}
  end

  def is_balanced({_name, _weight, _sum, []}), do: true
  def is_balanced(edge) do
    case get_unbalanced(edge) do
      [] -> true
      items ->
        IO.inspect (items)
        Enum.map(items, &is_balanced/1)
    end
  end

  def get_unbalanced({_name, _weight, _sum, children}), do: get_unbalanced(children)
  def get_unbalanced([]), do: []
  def get_unbalanced([a, b]), do: if sum(a) == sum(b), do: [], else: [a, b]
  def get_unbalanced(children) do
    {single_sums, _} = children
                  |> Enum.map(&sum/1)
                  |> Enum.reduce(%{}, fn (x, map) -> Map.update(map, x, 1, &(&1 + 1)) end)
                  |> Enum.filter(fn {key, val} -> val == 1 end)
                  |> Enum.unzip()
    Enum.filter(children, fn x -> Enum.member?(single_sums, sum(x)) end)
  end

  def sum({_name, _weight, sum, _children}), do: sum

  def find_root(items) when is_list(items) do
    candidates = Enum.filter(items, &has_children?/1)
    {root, _, _} = Enum.find(candidates, &has_no_parent?(&1, candidates))
    root
  end

  def parse_line(line) when is_binary(line) do
    regex = ~r/(?<name>\w+)\s+\((?<weight>\d+)\)( -> (?<children>.+))*/
    %{"children" => children, "name" => name, "weight" => weight} = Regex.named_captures(regex, line)
    child_set = if children == "" do
      :empty
    else
      String.split(children, [",", " "], trim: true) |> MapSet.new()
    end
    {name, String.to_integer(weight), child_set}
  end

  defp has_no_parent?({name, _, _}, list), do: has_no_parent?(name, list)
  defp has_no_parent?(name, list) when is_binary(name), do: Enum.all?(list, &(!is_child(name, &1)))

  defp is_child(name, {_name, _weight, children}), do: MapSet.member?(children, name)

  defp has_children?({_name, _weight, :empty}), do: false
  defp has_children?({_name, _weight, %MapSet{}}), do: true
end
