defmodule Day03 do

  @number_chars ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

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
    Application.app_dir(:aoc2024, "/priv/day03_example.txt")
  end

  def data_example_txt_2() do
    Application.app_dir(:aoc2024, "/priv/day03_example_2.txt")
  end

  def data_txt() do
    Application.app_dir(:aoc2024, "/priv/day03.txt")
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
          "mul" <> rest ->
            {parse_mul_args(rest) |> Enum.to_list(), rest}
          "do()" <> rest ->
            {[:do], rest}
          "don't()" <> rest ->
            {[:dont], rest}
          _ ->
            {[], String.slice(acc, 1..-1//1)}
        end
      end,
      fn _acc -> nil end
    )
  end

  def parse_mul_args(content) do
    Stream.resource(
      fn -> {content, :open, 0, 0, 0, 0} end,
      fn acc ->
        {content, mode, arg1, count1, arg2, count2} = acc
        next = String.first(content)
        rest = String.slice(content, 1..-1//1)
        case {next, mode} do
          {nil, _mode} ->
            {:halt, acc}
          {_content, :done} ->
            {:halt, acc}
          {"(", :open} ->
            {[], {rest, :arg1, arg1, count1, arg2, count2}}
          {num, :arg1} when count1 < 3 and num in @number_chars ->
            {val, _rem} = Integer.parse(num)
            {[], {rest, :arg1, (arg1 * 10) + val, count1 + 1, arg2, count2}}
          {",", :arg1} when count1 > 0 ->
            {[], {rest, :arg2, arg1, count1, arg2, count2}}
          {num, :arg2} when count2 < 3 and num in @number_chars ->
            {val, _rem} = Integer.parse(num)
            {[], {rest, :arg2, arg1, count1, (arg2 * 10) + val, count2 + 1}}
          {")", :arg2} when count2 > 0 ->
            {[{:mul, arg1, arg2}], {rest, :done, arg1, count1, arg2, count2}}
          _ ->
            {:halt, acc}
        end
      end,
      fn _acc -> nil end
    )
  end

  def process(operations) do
    operations
    |> Stream.map(fn op ->
      case op do
        {:mul, arg1, arg2} ->
          arg1 * arg2
        _ ->
          0
      end
    end)
  end

  def process2(operations, do_add \\ true) do
    operations
    |> Stream.transform(do_add, fn op, acc ->
      case op do
        {:mul, arg1, arg2} when acc ->
          {[arg1 * arg2], acc}
        {:mul, _arg1, _arg2} ->
          {[], acc}
        :do ->
          {[], true}
        :dont ->
          {[], false}
        _ ->
          {:halt, acc}
      end
    end)
  end
end
