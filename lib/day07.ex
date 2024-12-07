defmodule Day07 do
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
    Application.app_dir(:aoc2024, "/priv/day07_example.txt")
  end

  def data_txt() do
    Application.app_dir(:aoc2024, "/priv/day07.txt")
  end

  def load(file) do
    File.stream!(file, :line)
    |> Stream.map(fn line ->
      String.trim(line)
    end)
  end

  def parse_line(line) do
    [left, right] = line |> String.split(": ")
    {target, _rem} = Integer.parse(left)

    nums = right
    |> String.split()
    |> Enum.map(fn num ->
      {val, _rem} = num |> Integer.parse()
      val
    end)

    {target, nums}
  end

  def process({target, nums}, operations) do
    case nums do
      # success
      [only] when only == target -> target
      # failure fater the last operation
      [_] -> 0
      # failure before last operation, head is always increasing
      [head | _tail] when head > target -> 0
      # Fork and apply all operations on first and second
      _ ->
        {[first, second], tail} = nums |> Enum.split(2)
        operations |> Enum.map(fn op ->
          case op do
            :mul -> process({target, [first * second | tail]}, operations)
            :cat ->
              {joined, _rem} = "#{first}#{second}" |> Integer.parse()
              process({target, [joined | tail]}, operations)
            :add -> process({target, [first + second | tail]}, operations)
          end
        end)
        # Fork results are either 0 or the target, using max is equivalent to returning the target on any success
        |> Enum.max()
    end
  end

  def process1(data) do
    process(data, [:mul, :add])
  end

  def process2(data) do
    process(data, [:cat, :mul, :add])
  end

  def part1(file) do
    load(file)
    |> Stream.map(&parse_line/1)
    |> Stream.map(&process1/1)
    |> Enum.sum()
  end

  def part2(file) do
    load(file)
    |> Stream.map(&parse_line/1)
    |> Stream.map(&process2/1)
    |> Enum.sum()
  end
end
