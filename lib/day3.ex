defmodule Day3 do
  def run(src, part) do
    case {src, part} do
      {:test, 1} -> data_example_txt() |> part1()
      {:test, 2} -> data_example_txt_2() |> part2()
      {:input, 1} -> data_txt() |> part1()
      {:input, 2} -> data_txt() |> part2()
      _ -> {:error, "Invalid arguments. Expecting (:test | :input, 1 | 2)"}
    end
  end

  def data_example_txt() do
    Application.app_dir(:aoc2024, "/priv/day3_example.txt")
  end

  def data_example_txt_2() do
    Application.app_dir(:aoc2024, "/priv/day3_example_2.txt")
  end

  def data_txt() do
    Application.app_dir(:aoc2024, "/priv/day3.txt")
  end

  def part1(file) do
    File.read!(file)
    |> parse_command()
    |> process()
    |> Enum.to_list()
    |> Enum.sum()
  end

  def part2(file) do
    File.read!(file)
    |> parse_command()
    |> process2()
    |> Enum.to_list()
    |> Enum.sum()
  end

  def parse_command(content) do
    Stream.resource(
      fn -> content end,
      fn acc ->
        case acc do
          "" -> {:halt, acc}
          "mul" <> rest -> {parse_mul_args(rest) |> Enum.to_list(), rest}
          "do()" <> rest -> {[:do], rest}
          "don't()" <> rest -> {[:dont], rest}
          _ -> {[], String.slice(acc, 1..-1//1)}
        end
      end,
      fn _acc -> nil end
    )
  end

  def parse_mul_args(content) do
    Stream.resource(
      fn -> {content, :open, 0, 0, 0, 0} end,
      fn acc ->
        case acc do
          {"", _mode, _arg1, _count1, _arg2, _count2} -> {:halt, acc}
          {_content, :done, _arg1, _count1, _arg2, _count2} -> {:halt, acc}
          {"(" <> rest, :open, arg1, count1, arg2, count2} -> {[], {rest, :arg1, arg1, count1, arg2, count2}}
          {"0" <> rest, :arg1, arg1, count1, arg2, count2} when count1 < 3 -> {[], {rest, :arg1, arg1 * 10, count1 + 1, arg2, count2}}
          {"1" <> rest, :arg1, arg1, count1, arg2, count2} when count1 < 3 -> {[], {rest, :arg1, (arg1 * 10) + 1, count1 + 1, arg2, count2}}
          {"2" <> rest, :arg1, arg1, count1, arg2, count2} when count1 < 3 -> {[], {rest, :arg1, (arg1 * 10) + 2, count1 + 1, arg2, count2}}
          {"3" <> rest, :arg1, arg1, count1, arg2, count2} when count1 < 3 -> {[], {rest, :arg1, (arg1 * 10) + 3, count1 + 1, arg2, count2}}
          {"4" <> rest, :arg1, arg1, count1, arg2, count2} when count1 < 3 -> {[], {rest, :arg1, (arg1 * 10) + 4, count1 + 1, arg2, count2}}
          {"5" <> rest, :arg1, arg1, count1, arg2, count2} when count1 < 3 -> {[], {rest, :arg1, (arg1 * 10) + 5, count1 + 1, arg2, count2}}
          {"6" <> rest, :arg1, arg1, count1, arg2, count2} when count1 < 3 -> {[], {rest, :arg1, (arg1 * 10) + 6, count1 + 1, arg2, count2}}
          {"7" <> rest, :arg1, arg1, count1, arg2, count2} when count1 < 3 -> {[], {rest, :arg1, (arg1 * 10) + 7, count1 + 1, arg2, count2}}
          {"8" <> rest, :arg1, arg1, count1, arg2, count2} when count1 < 3 -> {[], {rest, :arg1, (arg1 * 10) + 8, count1 + 1, arg2, count2}}
          {"9" <> rest, :arg1, arg1, count1, arg2, count2} when count1 < 3 -> {[], {rest, :arg1, (arg1 * 10) + 9, count1 + 1, arg2, count2}}
          {"," <> rest, :arg1, arg1, count1, arg2, count2} when count1 > 0 -> {[], {rest, :arg2, arg1, count1, arg2, count2}}
          {"0" <> rest, :arg2, arg1, count1, arg2, count2} when count2 < 3 -> {[], {rest, :arg2, arg1, count1, arg2 * 10, count2 + 1}}
          {"1" <> rest, :arg2, arg1, count1, arg2, count2} when count2 < 3 -> {[], {rest, :arg2, arg1, count1, (arg2 * 10) + 1, count2 + 1}}
          {"2" <> rest, :arg2, arg1, count1, arg2, count2} when count2 < 3 -> {[], {rest, :arg2, arg1, count1, (arg2 * 10) + 2, count2 + 1}}
          {"3" <> rest, :arg2, arg1, count1, arg2, count2} when count2 < 3 -> {[], {rest, :arg2, arg1, count1, (arg2 * 10) + 3, count2 + 1}}
          {"4" <> rest, :arg2, arg1, count1, arg2, count2} when count2 < 3 -> {[], {rest, :arg2, arg1, count1, (arg2 * 10) + 4, count2 + 1}}
          {"5" <> rest, :arg2, arg1, count1, arg2, count2} when count2 < 3 -> {[], {rest, :arg2, arg1, count1, (arg2 * 10) + 5, count2 + 1}}
          {"6" <> rest, :arg2, arg1, count1, arg2, count2} when count2 < 3 -> {[], {rest, :arg2, arg1, count1, (arg2 * 10) + 6, count2 + 1}}
          {"7" <> rest, :arg2, arg1, count1, arg2, count2} when count2 < 3 -> {[], {rest, :arg2, arg1, count1, (arg2 * 10) + 7, count2 + 1}}
          {"8" <> rest, :arg2, arg1, count1, arg2, count2} when count2 < 3 -> {[], {rest, :arg2, arg1, count1, (arg2 * 10) + 8, count2 + 1}}
          {"9" <> rest, :arg2, arg1, count1, arg2, count2} when count2 < 3 -> {[], {rest, :arg2, arg1, count1, (arg2 * 10) + 9, count2 + 1}}
          {")" <> rest, :arg2, arg1, count1, arg2, count2} when count2 > 0 -> {[{:mul, arg1, arg2}], {rest, :done, arg1, count1, arg2, count2}}
          _ -> {:halt, acc}
        end
      end,
      fn _acc -> nil end
    )
  end

  def process(operations) do
    operations
    |> Stream.map(fn op ->
      case op do
        {:mul, arg1, arg2} -> arg1 * arg2
        _ -> 0
      end
    end)
  end

  def process2(operations, do_add \\ true) do
    operations
    |> Stream.transform(do_add, fn op, acc ->
      case op do
        {:mul, arg1, arg2} when acc -> {[arg1 * arg2], acc}
        {:mul, _arg1, _arg2} -> {[], acc}
        :do -> {[], true}
        :dont -> {[], false}
        _ -> {:halt, acc}
      end
    end)
  end
end
