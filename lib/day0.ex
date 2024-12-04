defmodule Day0 do
  def run(src, part) do
    case {src, part} do
      {:test, 1} -> data_example_txt() |> part1()
      {:test, 2} -> data_example_txt() |> part2()
      {:input, 1} -> data_txt() |> part1()
      {:input, 2} -> data_txt() |> part2()
    end
  end

  def data_example_txt() do
    Application.app_dir(:aoc2024, "/priv/day0_example.txt")
  end

  def data_txt() do
    Application.app_dir(:aoc2024, "/priv/day0.txt")
  end

  def part1(_file) do

  end

  def part2(_file) do

  end

  def parse_line(line) do
    line
  end
end
