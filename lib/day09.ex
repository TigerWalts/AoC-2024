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

  def preprocess2(numlist) do
    Stream.resource(
      fn -> {numlist, 0, :file} end,
      fn {input, i, state} ->
        case {state, input} do
          {_, []} -> {:halt, []}
          {:file, [head | tail]} -> {[{:file, head, i}], {tail, i + 1, :free}}
          {:free, [head | tail]} ->{[{:free, head}], {tail, i, :file}}
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

  def compact_queue(queue) do
    Stream.resource(
      fn -> {:tail, :queue.new(), queue, :queue.new(), nil} end,
      fn {state, stack, source, remain, candidate} ->
        case state do
          :done -> {:halt, {state, stack, source, remain, candidate}}
          :tail ->
            case :queue.out_r(source) do
              {:empty, q} ->
                # Source queue empty - Join the stack and remain queues nad emit the contents -> :done
                {:queue.join(stack, remain) |> :queue.to_list(), {:done, :queue.new(), q, :queue.new(), candidate}}

              {{:value, {:free, size}}, q} ->
                # Pulled a :free from the rear of source - Add it to the front of remain -> :tail
                {[], {:tail, stack, q, :queue.in_r({:free, size}, remain), candidate}}

              {{:value, {:file, size, id}}, q} ->
                # Pulled a :file from the rear of source - Set it as the candidate -> :head
                {[], {:head, stack, q, remain, {:file, size, id}}}
            end
          :head ->
            case :queue.out(source) do
              {:empty, q} ->
                # Source queue is empty - Add to front of remain -> :flush
                {[], {:flush, stack, q, :queue.in_r(candidate, remain), nil}}

              {{:value, {:free, size}}, q} ->
                # Pulled a :free from front of source - Compare size to candidate
                {:file, candidate_size, _id} = candidate
                case size - candidate_size do
                  0 ->
                    # Same size - Put the candidate on the rear of the stack and the :free on the front of the remain -> :flush
                    {[], {:flush, :queue.in(candidate, stack), q, :queue.in_r({:free, size}, remain), nil}}

                  n when n > 0 ->
                    # Candidate is smaller than the :free - Put the candidate on the rear of the stack followed by a :free of the size difference
                    # Put a free the same size as the candidate on the front of the remain -> :flush
                    {[], {:flush, :queue.in(candidate, stack), :queue.in_r({:free, n}, q), :queue.in_r({:free, candidate_size}, remain), nil}}

                  _ ->
                    # Candidtae is larger than the :free - Put the :free on the rear of the stack -> :head
                    {[], {:head, :queue.in({:free, size}, stack), q, remain, candidate}}
                end

              {{:value, {:file, size, id}}, q} ->
                # Pulled a :file from the front of source - Place on the rear of the stack -> :head
                {[], {:head, :queue.in({:file, size, id}, stack), q, remain, candidate}}
            end
          :flush ->
            case :queue.out(stack) do
              {:empty, q} ->
                # stack is empty -> :tail
                {[], {:tail, q, source, remain, candidate}}

              {{:value, {:free, _size}}, _q} ->
                # Pulled a :free from the front of the stack - Put the original stack at the front of the source -> :tail
                {[], {:tail, :queue.new(), :queue.join(stack, source), remain, candidate}}

              {{:value, {:file, size, id}}, q} ->
                # Pulled a :file from the front of the stack - Emit it -> :flush
                {[{:file, size, id}], {:flush, q, source, remain, candidate}}
            end
        end
      end,
      fn _acc -> nil end
    )
  end

  def expand(parts) do
    Stream.resource(
      fn -> parts end,
      fn parts ->
        case parts do
          [] -> {:halt, []}
          [{:free, size} | tail] ->
            ids = Stream.repeatedly(fn -> 0 end)
            |> Enum.take(size)
            {ids, tail}
          [{:file, size, id} | tail] ->
            ids = Stream.repeatedly(fn -> id end)
            |> Enum.take(size)
            {ids, tail}
        end
      end,
      fn _acc -> nil end
    )
  end

  def part1(file) do
    load(file)
    |> preprocess()
    |> Enum.to_list()
    |> :queue.from_list()
    |> process_queue()
    |> Stream.with_index()
    |> Stream.map(fn {e, i} -> e * i end)
    |> Enum.sum()
  end

  def part2(file) do
    load(file)
    |> preprocess2()
    |> Enum.to_list()
    |> :queue.from_list()
    |> compact_queue()
    |> Enum.to_list()
    |> expand()
    |> Stream.with_index()
    |> Stream.map(fn {e, i} -> e * i end)
    |> Enum.sum()
  end
end
