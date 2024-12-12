defmodule Day11 do
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
    Application.app_dir(:aoc2024, "/priv/day11_example.txt")
  end

  def data_txt() do
    Application.app_dir(:aoc2024, "/priv/day11.txt")
  end

  def load(file) do
    File.read!(file)
    |> String.trim()
    |> String.split()
  end

  # If the stone is engraved with the number 0, it is replaced by a stone engraved with the number 1.
  # If the stone is engraved with a number that has an even number of digits, it is replaced by two stones. The left half of the digits are engraved on the new left stone, and the right half of the digits are engraved on the new right stone. (The new numbers don't keep extra leading zeroes: 1000 would become stones 10 and 0.)
  # If none of the other rules apply, the stone is replaced by a new stone; the old stone's number multiplied by 2024 is engraved on the new stone.
  def ans({num, gen}, pid) do
    case gen do
      0 -> 1
      _ ->
        send(pid, {:get, {num, gen}, self()})
        receive do
          {:get, nil} ->
            mod2 = num |> String.length() |> Integer.mod(2)
            result = case {num, mod2} do
              {"0", _} ->
                ans({"1", gen - 1}, pid)
              {_, 0} ->
                {left, right} = num |> String.split_at(num |> String.length() |> div(2))
                {val, _rem} = right |> Integer.parse()
                ans({left, gen - 1}, pid) + ans({"#{val}", gen - 1}, pid)
              _ ->
                {val, _rem} = num |> Integer.parse()
                ans({"#{val * 2024}", gen - 1}, pid)
            end
            send(pid, {:put, {num, gen}, result})
            result
          {:get, result} -> result
        end
    end
  end

  def part1(file) do
    {:ok, pid} = Day11Cache.start_link()

    ans = load(file)
    |> Stream.map(fn num -> ans({num, 25}, pid) end) # num -> {num, generation}
    |> Enum.sum()

    send(pid, :halt)

    ans
  end

  def part2(file) do
    {:ok, pid} = Day11Cache.start_link()

    ans = load(file)
    |> Stream.map(fn num -> ans({num, 75}, pid) end) # num -> {num, generation}
    |> Enum.sum()

    send(pid, :halt)

    ans
  end

end

defmodule Day11Cache do
  def start_link do
    Task.start_link(fn -> loop(%{}) end)
  end

  defp loop(map) do
    receive do
      {:get_lazy, key, def_fn, caller} ->
        map = Map.put_new_lazy(map, key, fn ->
          def_fn.(key)
        end)
        send(caller, {:get_lazy, Map.get(map, key)})
        loop(map)
      {:get, key, caller} ->
        send(caller, {:get, Map.get(map, key)})
        loop(map)
      {:put, key, value} ->
        loop(Map.put(map, key, value))
      :halt -> nil
    end
  end
end
