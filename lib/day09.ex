defmodule Day09 do
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
    Application.app_dir(:aoc2024, "/priv/day09_example.txt")
  end

  def data_txt() do
    Application.app_dir(:aoc2024, "/priv/day09.txt")
  end

  def load(file) do
    line = File.read!(file)
    |> String.trim()
    for <<a::utf8 <- line>> do
      {val, _rem} = Integer.parse(<<a::utf8>>)
      val
    end
  end

  def preprocess(numlist) do
    Stream.resource(
      fn -> {numlist, 0, :file} end,
      fn {input, i, state} ->
        case {state, input} do
          {_, []} -> {:halt, []}
          {:file, [head | tail]} ->
            ids = Stream.repeatedly(fn -> i end)
            |> Enum.take(head)
            {ids, {tail, i + 1, :free}}
          {:free, [head | tail]} ->
            ids = Stream.repeatedly(fn -> nil end)
            |> Enum.take(head)
            {ids, {tail, i, :file}}
        end
      end,
      fn _acc -> nil end
    )
  end

  def process_queue(queue) do
    Stream.resource(
      fn -> {:head, queue} end,
      fn {state, queue} ->
        case state do
          :head ->
            case :queue.out(queue) do
              {:empty, empty_queue} -> {:halt, {:head, empty_queue}}
              {{:value, nil}, new_queue} -> {[], {:tail, new_queue}}
              {{:value, id}, new_queue} -> {[id], {:head, new_queue}}
            end
          :tail ->
            case :queue.out_r(queue) do
              {:empty, empty_queue} -> {:halt, {:tail, empty_queue}}
              {{:value, nil}, new_queue} -> {[], {:tail, new_queue}}
              {{:value, id}, new_queue} -> {[id], {:head, new_queue}}
            end
        end
      end,
      fn _queue -> nil end
    )
  end

  def part1(file) do
    load(file)
    |> preprocess()
    |> Enum.to_list()
    |> :queue.from_list()
    |> process_queue()
    |> Enum.to_list() |> IO.inspect()
    |> Stream.with_index()
    |> Stream.map(fn {e, i} -> e * i end)
    |> Enum.sum()
  end

  def part2(_file) do

  end
end
