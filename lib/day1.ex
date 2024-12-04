defmodule Day1 do
  def data_example_txt() do
    Application.app_dir(:aoc2024, "/priv/day1_example.txt")
  end

  def data_txt() do
    Application.app_dir(:aoc2024, "/priv/day1.txt")
  end

  def part1(file) do
    File.stream!(file)
    |> Stream.map(&parse_line/1)
    |> Stream.zip()
    |> Stream.map(fn tup ->
      tup
      |> Tuple.to_list()
      |> Enum.sort()
    end)
    |> Stream.zip()
    |> Stream.map(fn tup ->
      {a, b} = tup
      abs(a - b)
    end)
    |> Enum.to_list()
    |> Enum.sum()
  end

  def part2(file) do
    [left, right] = File.stream!(file)
    |> Stream.map(&parse_line/1)
    |> Stream.zip()
    |> Stream.map(fn tup ->
      tup
      |> Tuple.to_list()
      |> Enum.frequencies()
    end)
    |> Enum.to_list()
    Map.to_list(left)
    |> Enum.map(fn {k, v} ->
      Map.get(right, k, 0) * k * v
    end)
    |> Enum.sum()
  end

  def parse_line(line) do
    String.split(line)
    |> Enum.map(fn part ->
      {value, _rem} = Integer.parse(part)
      value
    end)
  end
end
