defmodule Day10 do
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
    Application.app_dir(:aoc2024, "/priv/day10_example.txt")
  end

  def data_txt() do
    Application.app_dir(:aoc2024, "/priv/day10.txt")
  end

  def load(file) do
    File.stream!(file)
    |> Stream.map(fn line ->
      line = line |> String.trim()
      for <<a::utf8 <- line>> do
        if <<a::utf8>> == "." do
          -1
        else
          {val, _rem} = Integer.parse(<<a::utf8>>)
          val
        end
      end
    end)
  end

  def get_grid_max_x_y(grid) do
    y_count = Enum.at(grid,0) |> Enum.count()
    {
      y_count - 1,
      Enum.count(grid) - 1
    }
  end

  def get_grid_trailheads(grid) do
    grid
    |> Stream.with_index(fn row, y ->
      row
      |> Stream.with_index(fn height, x ->
        {x, y, height}
      end)
      |> Stream.filter(fn {_x, _y, height} ->
        height == 0
      end)
    end)
    |> Stream.concat()
    |> Stream.with_index(fn {x, y, _height}, id ->
      {x, y, id}
    end)
  end

  def next_trailheads({x, y, id}, grid, next_height, max_x, max_y) do
    [{0, -1}, {-1, 0}, {1, 0}, {0, 1}]
    |> List.flatten()
    |> Stream.map(fn {dx, dy} -> {x + dx, y + dy} end)
    |> Stream.filter(fn {cx, cy} ->
      cx in 0..(max_x) and cy in 0..(max_y)
    end)
    |> Stream.filter(fn {cx, cy} ->
      candidate_height = Enum.at(grid, cy) |> Enum.at(cx)
      candidate_height == next_height
    end)
    |> Stream.map(fn {cx, cy} ->
      {cx, cy, id}
    end)
    |> Enum.to_list()
  end

  def process(grid, trailheads, max_x, max_y, rating_type) do
    # trailheads |> IO.inspect()
    Enum.reduce(
      1..9,
      trailheads,
      fn next_height, trailheads ->
        trailheads = trailheads
        |> Stream.map(fn trailhead ->
          trailhead |> next_trailheads(grid, next_height, max_x, max_y)
        end)
        |> Enum.to_list()
        |> List.flatten()

        case rating_type do
          :unique -> trailheads
          :pairs ->
            trailheads
            |> Enum.sort(fn {ax, ay, a_id}, {bx, by, b_id} ->
              case {by - ay, bx - ax, b_id - a_id} do
                {0, 0, diff} -> diff >= 0
                {0, diff, _} -> diff >= 0
                {diff, _, _} -> diff >= 0
              end
            end)
            |> Enum.dedup()
        end
      end
    )
  end

  def part1(file) do
    grid = load(file) |> Enum.to_list()

    {max_x, max_y} = get_grid_max_x_y(grid)

    trailheads = get_grid_trailheads(grid)
    |> Enum.to_list()

    process(grid, trailheads, max_x, max_y, :pairs)
    |> Enum.count()
  end

  def part2(file) do
    grid = load(file) |> Enum.to_list()

    {max_x, max_y} = get_grid_max_x_y(grid)

    trailheads = get_grid_trailheads(grid)
    |> Enum.to_list()

    process(grid, trailheads, max_x, max_y, :unique)
    |> Enum.count()
  end

  def parse_line(line) do
    line
  end
end
