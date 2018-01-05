defmodule Advent do
  defmodule Vector do
    defstruct [:size, :rows]

    def from_list(list) when is_list(list) do
      size = length(list) |> :math.sqrt() |> round()
      rows = Enum.chunk_every(list, size)
             |> Enum.map(fn x -> :array.from_list(x, nil) end)
      %Vector{size: size, rows: :array.from_list(rows, nil)}
    end

    def size(%Vector{size: size}), do: size

    def to_list(%Vector{rows: rows}) do
      :array.to_list(rows)
      |> Enum.map(fn r -> :array.to_list(r) end)
      |> Enum.concat()
    end

    def concat(vectors) when is_list(vectors) do
      chunk_size = length(vectors) |> :math.sqrt() |> round()
      vectors 
      |> Enum.chunk_every(chunk_size)
      |> Enum.map(&merge_vectors/1)
      |> Enum.concat()
      |> from_list()
    end

    def merge_vectors(list) when is_list(list) do
      Enum.reduce(list, %{}, fn (v, map) -> merge_maps(map, merge_vector(v)) end)
      |> Map.values()
      |> Enum.concat()
    end

    def merge_vector(%Vector{rows: rows}) do
      :array.foldl(fn (idx, row, map) -> 
        list = :array.to_list(row)
        Map.update(map, idx, list, fn ex -> Enum.concat(ex, list) end)
      end, %{}, rows)
    end

    def chunk(v = %Vector{size: size}) do
      cond do
        rem(size, 2) == 0 -> chunk(v, 2)
        rem(size, 3) == 0 -> chunk(v, 3)
        true -> raise("size error")
      end
    end

    def chunk(%Vector{rows: rows}, new_size) do
      :array.to_list(rows)
      |> Enum.chunk_every(new_size)
      |> Enum.map(fn r -> chunk_row(r, new_size) end)
      |> Enum.concat()
    end

    def chunk_row(row, size) when is_list(row) do
      row
      |> Enum.map(fn r -> :array.to_list(r) |> Enum.chunk_every(size) |> enum_to_map()  end)
      |> Enum.reduce(%{}, fn (row, acc) -> merge_maps(acc, row) end)
      |> Map.to_list()
      |> Enum.sort_by(&elem(&1, 0))
      |> Enum.map(fn {_, v} -> from_list(v) end)
    end

    def merge_maps(m1, m2) do
      Map.merge(m1, m2, fn (_, l1, l2) -> Enum.concat(l1, l2) end)
    end

    def enum_to_map(list) when is_list(list) do
      Enum.with_index(list) |> Map.new(fn {x, idx} -> {idx, x} end)
    end

    def list_variants(v = %Vector{}) do
      list = to_list(v)
      rotated90 = rotate(list, 90)
      [
        list,
        flip_hor(v) |> to_list(),
        flip_ver(v) |> to_list(),
        rotated90,
        rotate(list, 180),
        rotate(list, 270),
        from_list(rotated90) |> flip_hor() |> to_list(),
        from_list(rotated90) |> flip_ver() |> to_list(),
      ]
    end

    def flip_hor(v = %Vector{rows: rows}) do
      new_rows = :array.map(fn (_, row) -> reverse(row) end, rows)
      %{v | rows: new_rows}
    end

    def flip_ver(v = %Vector{rows: rows}) do
      %{v | rows: reverse(rows)}
    end

    defp rotate(list, 180) when is_list(list), do: Enum.reverse(list)
    defp rotate([a0, a1, a2, a3, a4, a5, a6, a7, a8], 90), do: [a2, a5, a8, a1, a4, a7, a0, a3, a6]
    defp rotate([a0, a1, a2, a3, a4, a5, a6, a7, a8], 270), do: [a6, a3, a0, a7, a4, a1, a8, a5, a2]

    defp rotate([a0, a1, a2, a3], 90), do: [a1, a3, a0, a2]
    defp rotate([a0, a1, a2, a3], 270), do: [a2, a0, a3, a1]

    defp reverse(array) do
      :array.to_list(array)
      |> Enum.reverse()
      |> :array.from_list()
    end
  end

  @initial_pattern [0,1,0,0,0,1,1,1,1]

  def solve(input, iterations) do
    rules = parse(input)
    initial_vector = Vector.from_list(@initial_pattern)
    iter(initial_vector, rules, iterations) |> on()
  end

  def dump(vector) do
    Vector.to_list(vector)
    |> Enum.chunk_every(Vector.size(vector))
    |> Enum.map(fn row -> to_pixels(row) |> Enum.join() |> IO.puts() end)
    :ok
  end

  def iter(vector, _, 0), do: vector
  def iter(vector, rules, counter) do
    new_vec = iterate(vector, rules)
    iter(new_vec, rules, counter - 1)
  end

  def iterate(vector, rules) do
    vector
    |> Vector.chunk()
    |> Enum.map(fn v -> enhance(v, rules) end)
    |> Vector.concat()
  end

  def enhance(vector, rules) do
    rules = rules[Vector.size(vector)]
    vector
    |> Vector.list_variants()
    |> Enum.find_value(fn x -> rules[x] end)
    |> Vector.from_list()
  end

  def count_on(list), do: Enum.count(list, fn x -> x == 1 end)

  def initial_pattern(), do: @initial_pattern

  def parse(input) do
    input 
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.group_by(fn {size, _src, _dst} -> size end, fn {_, src, dst} -> {src, dst} end)
    |> Enum.map(fn {size, data} -> {size, Map.new(data)} end)
    |> Map.new()
  end

  def parse_line(line) do
    [src, dst] = line 
                 |> String.replace("/", "") 
                 |> String.replace(".", "0") 
                 |> String.replace("#", "1") 
                 |> String.split(" => ")
    {round(:math.sqrt(String.length(src))), parse_pixels(src), parse_pixels(dst)}
  end

  def parse_pixels(str), do: String.to_charlist(str) |> Enum.map(&(&1 - ?0))

  def to_pixels(list) do
    Enum.map(list, fn 1 -> "#"
                      0 -> "."
    end)
  end

  def on(vector) do
    Vector.to_list(vector) |> Enum.count(fn x -> x == 1 end)
  end

  def rev(size) do
    list = Enum.to_list(0..size*size-1)
    list2 = Vector.from_list(list) |> Vector.chunk() |> Vector.concat() |> Vector.to_list()
    {list == list2, list, list2}
  end
end

