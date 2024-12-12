defmodule Aoc2024Test do
  use ExUnit.Case
  doctest Aoc2024

  test "Day 1 Part 1 Test 1" do
    assert Day01.run(:test, 1) == 11
  end

  test "Day 1 Part 2 Test 1" do
    assert Day01.run(:test, 2) == 31
  end

  test "Day 2 Part 1 Test 1" do
    assert Day02.run(:test, 1) == 2
  end

  test "Day 2 Part 2 Test 1" do
    assert Day02.run(:test, 2) == 4
  end

  test "Day 3 Part 1 Test 1" do
    assert Day03.run(:test, 1) == 161
  end

  test "Day 3 Part 2 Test 1" do
    assert Day03.run(:test, 2) == 48
  end

  test "Day 4 Part 1 Test 1" do
    assert Day04.run(:test, 1) == 18
  end

  test "Day 4 Part 2 Test 1" do
    assert Day04.run(:test, 2) == 9
  end

  test "Day 5 Part 1 Test 1" do
    assert Day05.run(:test, 1) == 143
  end

  test "Day 5 Part 2 Test 1" do
    assert Day05.run(:test, 2) == 123
  end

  test "Day 6 Part 1 Test 1" do
    assert Day06.run(:test, 1) == 41
  end

  test "Day 6 Part 2 Test 1" do
    assert Day06.run(:test, 2) == 6
  end

  test "Day 7 Part 1 Test 1" do
    assert Day07.run(:test, 1) == 3749
  end

  test "Day 7 Part 2 Test 1" do
    assert Day07.run(:test, 2) == 11387
  end

  test "Day 8 Part 1 Test 1" do
    assert Day08.run(:test, 1) == 14
  end

  test "Day 8 Part 2 Test 1" do
    assert Day08.run(:test, 2) == 34
  end

  test "Day 9 Part 1 Test 1" do
    assert Day09.run(:test, 1) == 1928
  end

  test "Day 9 Part 2 Test 1" do
    assert Day09.run(:test, 2) == 2858
  end

  test "Day 10 Part 1 Test 1" do
    assert Day10.run(:test, 1) == 36
  end

  test "Day 10 Part 2 Test 1" do
    assert Day10.run(:test, 2) == 81
  end

  test "Day 11 Part 1 Test 1" do
    assert Day11.run(:test, 1) == 55312
  end
end
