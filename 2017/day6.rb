require 'minitest'
require 'byebug'
require 'set'

class Reallocation
  include Enumerable

  def initialize(initial_state)
    @enumerator = Enumerator.new do |y|
      state = initial_state.dup

      loop do
        blocks_to_reallocate = state.max
        bank_to_reallocate = state.index(blocks_to_reallocate)
        state[bank_to_reallocate] = 0

        ((bank_to_reallocate + 1)..(bank_to_reallocate + blocks_to_reallocate))
          .map { |i| i % state.size }
          .each { |i| state[i] += 1 }

        y << state.dup
      end
    end
  end

  def cycles_before_loop
    lazy
      .with_object(Set.new)
      .map { |state, seen| seen.include?(state).tap { seen << state } }
      .find_index(true) + 1
  end

  def loop_length
    cycles_before_loop - lazy.find_index(lazy.first(cycles_before_loop).last) - 1
  end

  def each(&block)
    @enumerator.each(&block)
  end
end

class TestPart1 < Minitest::Test
  def test_reallocation
    assert_equal [
      [2, 4, 1, 2],
      [3, 1, 2, 3],
      [0, 2, 3, 4],
      [1, 3, 4, 1],
      [2, 4, 1, 2]
    ], Reallocation.new([0, 2, 7, 0]).first(5)
  end

  def test_cycles_before_loop
    assert_equal 5, Reallocation.new([0, 2, 7, 0]).cycles_before_loop
  end

  def test_solution
    assert_equal 11137, Reallocation.new(File.read("day6.input").gsub("\n", "").split("\t").map(&:to_i)).cycles_before_loop
  end
end

class TestPart2 < Minitest::Test
  def test_loop_length
    assert_equal 4, Reallocation.new([0, 2, 7, 0]).loop_length
  end

  def test_solution
    assert_equal 1037, Reallocation.new(File.read("day6.input").gsub("\n", "").split("\t").map(&:to_i)).loop_length
  end
end

Minitest.autorun
