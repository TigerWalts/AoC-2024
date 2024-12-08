defmodule Day08 do
  def run(src, part) do
    case {src, part} do
      {:test, 1} -> data_example_txt() |> part1()
      {:test, 2} -> data_example_txt() |> part2()
      {:input, 1} -> data_txt() |> part1()
      {:input, 2} -> data_txt() |> part2()
      _ -> {:error, "Invalid arguments. Expecting (:test | :input, 1 | 2)"}
    end
  end

  def load(file) do
    File.stream!(file, :line)
    |> Stream.map(fn line ->
      line = String.trim(line)
      for <<a::utf8 <- line>>, do: <<a::utf8>>
    end)
  end

  def preprocess(stream) do
    stream
    |> Stream.with_index(fn line, y ->
      line
      |> Enum.with_index(fn c, x ->
        case c do
          "." -> {:empty, {x,y}}
          c -> {c, {x,y}}
        end
      end)
    end)
    |> Stream.concat()
  end

  def collate(stream) do
    stream
    |> Enum.reduce(
      {Map.new(), {0, 0}},
      fn {freq, {x, y}}, {locs, {max_x, max_y}} ->
        locs = case freq do
          :empty -> locs
          _ ->
            locs
            |> Map.update(
              freq,
              [{x, y}],
              fn locs ->
                [{x, y} | locs]
              end
            )
        end

        {
          locs,
          {max(x, max_x), max(y, max_y)}
        }
      end
    )
  end

  def pairs(list) do
    Stream.resource(
      fn -> list end,
      fn list ->
        case list do
          [] -> {:halt, []}
          [_head] -> {:halt, []}
          [head | tail] ->
            {
              tail |> Enum.map(& {head, &1}) |> Enum.to_list(),
              tail
            }
        end
      end,
      fn _list -> nil end
    )
  end

  def get_antinodes(towers) do
    towers
    |> pairs()
    |> Stream.map(fn pair ->
      Stream.resource(
        fn -> pair end,
        fn pair ->
          case pair do
            nil -> {:halt, nil}
            {{x1, y1}, {x2, y2}} ->
              {dx, dy} = {x2 - x1, y2 - y1}
              {[{x1 - dx, y1 - dy}, {x2 + dx, y2 + dy}], nil}
          end
        end,
        fn _pair -> nil end
      )
    end)
    |> Stream.concat()
  end

  def in_bounds({test_x, test_y}, {max_x, max_y}) do
    test_x in 0..max_x and test_y in 0..max_y
  end

  def data_example_txt() do
    Application.app_dir(:aoc2024, "/priv/day08_example.txt")
  end

  def data_txt() do
    Application.app_dir(:aoc2024, "/priv/day08.txt")
  end

  def part1(file) do
    {freq_towers, max} = load(file)
    |> preprocess()
    |> collate()

    freq_towers
    |> Map.values()
    |> Stream.map(fn towers ->
      towers
      |> get_antinodes()
      |> Stream.reject(& not in_bounds(&1, max))
    end)
    |> Stream.concat()
    |> MapSet.new()
    |> MapSet.size()
  end

  def part2(_file) do

  end

  def parse_line(line) do
    line
  end
end
