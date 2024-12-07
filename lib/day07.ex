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

    {target, nums}
  end

  def process1({target, nums}, acc \\ 0) do
    case nums do
      [] when acc == target -> {:pass, target}
      [] -> :fail
      _ when acc > target -> :fail # acc is always increasing
      _ ->
        [head | tail] = nums
        {operand, _rem} = Integer.parse(head)
        mul = if acc == 0 do
          process1({target, tail}, operand)
        else
          process1({target, tail}, acc * operand)
        end
        add = process1({target, tail}, acc + operand)
        case {add, mul} do
          {{:pass, target}, _} -> {:pass, target}
          {_, {:pass, target}} -> {:pass, target}
          _ -> :fail
        end
    end
  end

  def process2({target, nums}, acc \\ 0) do
    case nums do
      [] when acc == target -> {:pass, target}
      [] -> :fail
      _ when acc > target -> :fail # acc is always increasing
      _ ->
        [head | tail] = nums
        {operand, _rem} = Integer.parse(head)
        mul = if acc == 0 do
          process2({target, tail}, operand)
        else
          process2({target, tail}, acc * operand)
        end
        {joined, _rem} = "#{acc}" <> head |> Integer.parse()
        cat = process2({target, tail}, joined)
        add = process2({target, tail}, acc + operand)
        if [cat, add, mul] |> Enum.any?(& &1 != :fail) do
          {:pass, target}
        else
          :fail
        end
    end
  end

  def part1(file) do
    load(file)
    |> Stream.map(&parse_line/1)
    |> Stream.map(&process1/1)
    |> Stream.reject(& &1 == :fail)
    |> Stream.map(fn {:pass, target} -> target end)
    |> Enum.sum()
  end

  def part2(file) do
    load(file)
    |> Stream.map(&parse_line/1)
    |> Stream.map(&process2/1)
    |> Stream.reject(& &1 == :fail)
    |> Stream.map(fn {:pass, target} -> target end)
    |> Enum.sum()
  end
end
