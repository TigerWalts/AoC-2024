defmodule Day5 do
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
    Application.app_dir(:aoc2024, "/priv/day5_example.txt")
  end

  def data_txt() do
    Application.app_dir(:aoc2024, "/priv/day5.txt")
  end

  def part1(file) do
    {rules, updates} = File.stream!(file)
    |> Stream.map(&String.trim/1)
    |> preprocess()

    check(updates, rules)
    |> process(:ok)
    |> Enum.sum()
  end

  def part2(file) do
    {rules, updates} = File.stream!(file)
    |> Stream.map(&String.trim/1)
    |> preprocess()

    check(updates, rules)
    |> process(:fix)
    |> Enum.sum()
  end

  def preprocess(lines) do
    {_, rules, updates} = lines
    |> Stream.map(&String.trim/1)
    |> Enum.reduce({:rule, [], []}, fn line, {mode, rules, updates} ->
      case mode do
        :rule when line == "" ->
          {:update, rules, updates}
        :rule ->
          {:rule, [parse_rule_line(line) | rules], updates}
        :update ->
          {:update, rules, [parse_update_line(line) | updates]}
      end
    end)
    {rules, updates}
  end

  def process(updates, filter \\ :fix) do
    updates
    |> Enum.filter(fn {result, _update} -> result == filter end)
    |> Enum.map(fn {_result, update} ->
      middle = update |> Enum.count() |> Integer.floor_div(2)
      {val, _rem} = update |> Enum.at(middle) |> Integer.parse()
      val
    end)
  end

  def check(updates, rules) do
    updates
    |> Enum.map(fn update ->
      sorted = update
      |> Enum.sort(fn (a, b) ->
        case {[a, b] in rules, [b, a] in rules} do
          {true, false} -> true
          {false, true} -> false
          {false, false} -> throw("No rule found for: #{[a,b]}, maybe we should ignore this") # e.g. return true
          {true, true} -> throw("There are 2 rules with the same values but flipped: #{[a,b]} & #{[b,a]}")
        end
      end)
      if sorted == update do
        {:ok, update}
      else
        {:fix, sorted}
      end
    end)
  end

  def parse_rule_line(line) do
    line
      |> String.split("|")
  end

  def parse_update_line(line) do
    line
      |> String.split(",")
  end
end
