defmodule Day2 do
  def data_example_txt() do
    Application.app_dir(:aoc2024, "/priv/day2_example.txt")
  end

  def data_txt() do
    Application.app_dir(:aoc2024, "/priv/day2.txt")
  end

  def part1(file) do
    File.stream!(file)
    |> Stream.map(&parse_line/1)
    |> Stream.map(&analyse_report/1)
    |> Stream.filter(& &1 == :safe)
    |> Enum.to_list()
    |> Enum.count()
  end

  def part2(file) do
    File.stream!(file)
    |> Stream.map(&parse_line/1)
    |> Stream.map(&analyse_report_marginal/1)
    |> Stream.filter(& &1 == :safe)
    |> Enum.to_list()
    |> Enum.count()
  end

  def analyse_report_marginal(report) do
    max_index = Enum.count(report) - 1
    reports = [report] ++ (0..max_index
    |> Enum.map(fn n ->
      left = case n do
        0 -> []
        _ -> report |> Enum.slice(0..(n-1))
      end
      right = report |> Enum.drop(n + 1)
      left ++ right
    end))
    if Enum.any?(reports, fn report ->
      analyse_report(report) == :safe
    end) do
      :safe
    else
      :unsafe
    end
  end

  def analyse_report(report) do
    processed = report
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn pair ->
      [a, b] = pair
      b - a
    end)
    |> Enum.map(fn diff ->
      interval = case abs(diff) do
        0 -> :unsafe
        1 -> :safe
        2 -> :safe
        3 -> :safe
        _ -> :unsafe
      end
      dir = case diff do
        diff when diff < 0 -> :desc
        diff when diff == 0 -> :same
        _ -> :asc
      end
      {interval, dir}
    end)
    result = processed |> Enum.all?(fn {interval, _dir} ->
      interval == :safe
    end)
    && (
      processed |> Enum.all?(fn {_interval, dir} ->
        dir == :desc
      end)
      || processed |> Enum.all?(fn {_interval, dir} ->
        dir == :asc
      end)
    )
    case result do
      true -> :safe
      false -> :unsafe
    end
  end

  def parse_line(line) do
    line
    |> String.split()
    |> Enum.map(fn num ->
      {val, _rem} = Integer.parse(num)
      val
    end)
  end
end
