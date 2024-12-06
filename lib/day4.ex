defmodule Day4 do
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
    Application.app_dir(:aoc2024, "/priv/day4_example.txt")
  end

  def data_txt() do
    Application.app_dir(:aoc2024, "/priv/day4.txt")
  end

  def part1(file) do
    load(file)
    |> transformations()
    |> Enum.concat()
    |> process1()
  end

  def part2(file) do
    load(file)
    |> diag_3_with_row_column()
    |> Enum.reject(fn {test, _r_c} -> test != "MAS" end)
    |> Enum.frequencies_by(fn {_test, r_c} -> r_c end)
    |> Map.filter(fn {_r_c, count} -> count > 1 end)
    |> Map.keys()
    |> Enum.count()
  end

  def load(file) do
    File.stream!(file, :line)
    |> Stream.map(fn line ->
      line = String.replace(line, "\n", "")
      for <<a::utf8 <- line>>, do: <<a::utf8>>
    end)
    |> Enum.to_list()
  end

  def process1(rows) do
    rows
    |> Stream.map(fn row -> row |> Enum.join() end)
    |> Stream.map(fn line ->
      line
      |> Stream.unfold(fn line ->
        len = line |> String.length()
        case line do
          _ when len < 4 ->
            nil
          "XMAS" <> rest ->
            {1, rest}
          line ->
            {0, line |> String.slice(1..-1//1)}
        end
      end)
      |> Enum.to_list()
      |> Enum.sum()
    end)
    |> Enum.to_list()
    |> Enum.sum()
  end

  def flip(matrix) do
    Stream.resource(
      fn -> matrix end,
      fn matrix ->
        case matrix do
          [] -> {:halt, matrix}
          [row] -> {[row |> Enum.reverse()], []}
          [row | rest] -> {[row |> Enum.reverse()], rest}
        end
      end,
      fn _acc -> nil end
    )
    |> Enum.to_list()
  end

  def invert(matrix) do
    Stream.resource(
      fn -> matrix |> Enum.reverse() end,
      fn matrix ->
        case matrix do
          [] -> {:halt, matrix}
          [row] -> {[row], []}
          [row | rest] -> {[row], rest}
        end
      end,
      fn _acc -> nil end
    )
    |> Enum.to_list()
  end

  def transpose(matrix) do
    Stream.resource(
      fn -> matrix end,
      fn matrix ->
        row = matrix
          |> Enum.map(fn row ->
            row |> Enum.at(0)
          end)
          |> Enum.reject(& &1 == nil)
        if Enum.count(row) == 0 do
          {:halt, matrix}
        else
          {
            [row],
            matrix |> Enum.map(fn row ->
              Enum.slice(row, 1..-1//1)
            end)
          }
        end
      end,
      fn _acc -> nil end
    )
    |> Enum.to_list()
  end

  def diag_3_with_row_column(matrix) do
    rows = matrix |> Enum.count()
    cols = matrix |> Enum.map(& &1 |> Enum.count()) |> Enum.max()
    for r <- 1..(rows - 2) do
      for c <- 1..(cols - 2) do
        [
          [{r-1, c-1}, {r, c}, {r+1, c+1}],
          [{r+1, c+1}, {r, c}, {r-1, c-1}],
          [{r+1, c-1}, {r, c}, {r-1, c+1}],
          [{r-1, c+1}, {r, c}, {r+1, c-1}],
        ]
      end
      |> Enum.concat()
    end
    |> Enum.concat()
    |> Enum.map(fn triple ->
      {
        triple
        |> Enum.map(fn {r, c} ->
          matrix
          |> Enum.at(r)
          |> Enum.at(c)
        end)
        |> Enum.join(""),
        triple |> Enum.at(1)
      }
    end)
  end

  def rot_45(matrix) do
    #         0,0
    #     1,0     0,1
    # 2,0     1,1     0,2
    #     2,1     1,2     0,3
    #         2,2     1,3
    #             2,3
    row_count = Enum.count(matrix)
    Stream.resource(
      fn ->
        Stream.with_index(
          matrix,
          fn row, i ->
            if i == 0 do
              row
            else
              (for _ <- 1..i, do: nil) ++ row
            end
          end
        )
        |> Enum.to_list()
      end,
      fn matrix ->
        row = 1..row_count
          |> Enum.map(fn i ->
            matrix
            |> Enum.at(i - 1)
            |> Enum.at(0)
          end)
          |> Enum.reject(& &1 == nil)
        if Enum.count(row) == 0 do
          {:halt, matrix}
        else
          {
            [row],
            matrix |> Enum.map(fn row ->
              Enum.slice(row, 1..-1//1)
            end)
          }
        end
      end,
      fn _acc -> nil end
    )
    |> Enum.to_list()
  end

  def transformations(matrix) do
    [
      matrix,                 # L->R
      matrix |> flip(),       # R->L
      matrix |> transpose(),  # T->B
      matrix
        |> transpose()
        |> flip(),            # B->T
      matrix |> rot_45(),     # TR->BL
      matrix
        |> rot_45()
        |> flip(),            # BL->TR
      matrix
        |> flip()
        |> rot_45(),          # TL->BR
      matrix
        |> flip()
        |> rot_45()
        |> flip(),            # BR->TL
    ]
  end
end
