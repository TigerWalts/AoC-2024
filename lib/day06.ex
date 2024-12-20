defmodule Day06 do
  def run(src, part) do
    case {src, part} do
      {:test, 1} -> data_example_txt() |> part1()
      {:test, 2} -> data_example_txt() |> part2()
      {:input, 1} -> data_txt() |> part1()
      {:input, 2} -> data_txt() |> part2()
      _ -> {:error, "Invalid arguments. Expecting (:test | :input, 1 | 2)"}
    end
  end

  def data_example_txt() do
    Application.app_dir(:aoc2024, "/priv/day06_example.txt")
  end

  def data_txt() do
    Application.app_dir(:aoc2024, "/priv/day06.txt")
  end

  def load(file) do
    File.stream!(file, :line)
    |> Stream.map(fn line ->
      line = String.replace(line, "\n", "")
      for <<a::utf8 <- line>>, do: <<a::utf8>>
    end)
  end

  def part1(file) do
    {guard, blocks, max} = load(file)
    |> preprocess1()
    |> collate1()

    {max_x, max_y} = max

    {_pos, _facing, visited} = process1(guard, blocks, max_x, max_y)

    # draw_grid(max, pos, facing, blocks, visited)

    visited |> MapSet.size()
  end

  def part2(file) do
    {guard, blocks, max} = load(file)
    |> preprocess1()
    |> collate1()

    {max_x, max_y} = max

    {_pos, _facing, visited} = process1(guard, blocks, max_x, max_y)

    visited
    |> MapSet.delete(guard)
    |> Stream.map(fn new_block ->
      new_blocks = blocks |> MapSet.put(new_block)
      Stream.cycle([nil])
      |> Enum.reduce_while(
        {guard, :u, MapSet.new()}, # {guard loc, facing, visited}
        fn _i, {pos, facing, visited} ->
          will_loop = {pos, facing} in visited
          new_pos = move(pos, facing)
          blocked = new_pos in new_blocks
          in_bounds = in_bounds(pos, max_x, max_y)
          case {will_loop, blocked, in_bounds} do
            {true, false, _} -> {:halt, {{:loop, new_block}, new_pos, facing, visited}}
            {_, _, false} -> {:halt, {:exit, new_pos, facing, visited}}
            {_, true, _} -> {:cont, {pos, facing |> next_facing(), visited}}
            _ -> {:cont, {new_pos, facing, visited |> MapSet.put({pos, facing})}}
          end
        end
      )
    end)
    |> Stream.reject(fn {term, _pos, _facing, _visited} -> term == :exit end)
    |> Enum.count()
  end

  def preprocess1(stream) do
    stream
    |> Stream.with_index(fn line, y ->
      line
      |> Enum.with_index(fn c, x ->
        case c do
          "." -> {:empty, {x,y}}
          "#" -> {:block, {x,y}}
          "^" -> {:guard, {x,y}}
          c -> throw("Error : Unexpected character '#{c}' at #{{x,y}}")
        end
      end)
    end)
    |> Stream.concat()
  end

  def collate1(stream) do
    stream
    |> Enum.reduce(
      {nil, MapSet.new(), {0,0}},
      fn {type, {x, y}}, {guard, blocks, max} ->
        {max_x, max_y} = max
        new_max = {max(x, max_x), max(y, max_y)}
        case type do
          :empty -> {guard, blocks, new_max}
          :block -> {guard, blocks |> MapSet.put({x, y}), new_max}
          :guard ->
            if guard != nil do
              throw("Error : Found a second guard, first: #{guard}, second: #{{x, y}}")
            else
              {{x,y}, blocks, new_max}
            end
        end
      end
    )
  end

  def process1(guard, blocks, max_x, max_y) do
    Stream.cycle([nil])
    |> Enum.reduce_while(
      {guard, :u, MapSet.new()}, # {guard loc, facing, visited}
      fn _i, {pos, facing, visited} ->
        new_pos = move(pos, facing)
        blocked = new_pos in blocks
        in_bounds = in_bounds(pos, max_x, max_y)
        case {blocked, in_bounds} do
          {_, false} -> {:halt, {new_pos, facing, visited}}
          {true, _} -> {:cont, {pos, facing |> next_facing(), visited}}
          _ -> {:cont, {new_pos, facing, visited |> MapSet.put(pos)}}
        end
      end
    )
  end

  def move(pos, facing) do
    {x, y} = pos
    case facing do
      :u -> {x, y - 1}
      :r -> {x + 1, y}
      :d -> {x, y + 1}
      :l -> {x - 1, y}
    end
  end

  def in_bounds(pos, max_x, max_y) do
    {x, y} = pos
    x in 0..max_x and y in 0..max_y
  end

  def next_facing(facing) do
    case facing do
      :u -> :r
      :r -> :d
      :d -> :l
      :l -> :u
    end
  end

  def draw_grid(max, pos, facing, blocks, visited) do
    {max_x, max_y} = max
    for y <- 0..max_y do
      0..max_x |> Enum.map(fn x ->
        is_guard = {x, y} == pos
        is_block = {x, y} in blocks
        is_visited = {x, y} in visited
        case {is_guard, is_block, is_visited} do
          {true, _, _} ->
            case facing do
              :u -> "^"
              :r -> ">"
              :d -> "v"
              :l -> "<"
            end
          {_, true, _} -> "#"
          {_, _, true} -> "X"
          _ -> "."
        end
      end)
      |> Enum.join("")
      |> IO.puts()
    end
  end
end
