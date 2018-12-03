require 'minitest'
require 'byebug'
require 'set'

class FrequencyChanges
  def initialize(input)
    @changes = input.each_line.map { |line| line.to_i }
  end

  def resulting_frequency
    @changes.sum
  end

  def frequencies
    current = 0
    @changes.cycle.lazy.map { |change| current += change }
  end
end

class DuplicateDetector
  def initialize(frequencies)
    @frequencies = frequencies
  end

  def first_duplicate
    seen = Set.new

    @frequencies.each do |frequency|
      if seen.include?(frequency)
        return frequency
      else
        seen << frequency
      end
    end
  end
end

class TestPart1 < Minitest::Test
  def test_1
    input =
    %{+1
      -2
      +3
      +1}
    assert_equal 3, FrequencyChanges.new(input).resulting_frequency
  end
end

class TestPart2 < Minitest::Test
  def test_1
    input =
    %{+1
      -2
      +3
      +1}
    assert_equal [1, -1, 2, 3, 4, 2], FrequencyChanges.new(input).frequencies.first(6)
    assert_equal 2, DuplicateDetector.new(FrequencyChanges.new(input).frequencies).first_duplicate
  end
end

puts "Solution to part 1: #{FrequencyChanges.new(File.read("day1.input")).resulting_frequency}"
puts "Solution to part 2: #{DuplicateDetector.new(FrequencyChanges.new(File.read("day1.input")).frequencies).first_duplicate}"

Minitest.autorun
