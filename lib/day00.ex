defmodule Day00 do
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
    Application.app_dir(:aoc2024, "/priv/day00_example.txt")
  end

  def data_txt() do
    Application.app_dir(:aoc2024, "/priv/day00.txt")
  end

  def part1(_file) do

  end

  def part2(_file) do

  end

  def parse_line(line) do
    line
  end
end
