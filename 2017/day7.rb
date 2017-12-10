require 'minitest'
require 'byebug'
require 'strscan'
require 'set'

class Tower
  def self.parse(inputs)
    program_weights = {}
    program_parents = {}

    inputs.each do |input|
      scanner = StringScanner.new(input.gsub("\n", ""))

      parent_name = scanner.scan(/([a-z]+)/)
      scanner.scan(/ \(/)
      weight = scanner.scan(/\d+/)
      scanner.scan(/\)/)

      program_weights[parent_name] = weight

      until scanner.eos?
        scanner.scan(/( -> )|(, )/)
        child_name = scanner.scan(/[a-z]+/)

        program_parents[child_name] = parent_name
      end
    end

    Tower.new(program_weights, program_parents)
  end

  def initialize(program_weights, program_parents)
    @program_weights = program_weights
    @program_parents = program_parents
  end

  def root
    (@program_weights.keys - @program_parents.keys).first
  end
end

class TestPart1 < Minitest::Test
  def test_example_input
    input = [
      "pbga (66)",
      "xhth (57)",
      "ebii (61)",
      "havc (66)",
      "ktlj (57)",
      "fwft (72) -> ktlj, cntj, xhth",
      "qoyq (66)",
      "padx (45) -> pbga, havc, qoyq",
      "tknk (41) -> ugml, padx, fwft",
      "jptl (61)",
      "ugml (68) -> gyxo, ebii, jptl",
      "gyxo (61)",
      "cntj (57)"
    ]
    assert_equal "tknk", Tower.parse(input).root
  end

  def test_challenge_input
    assert_equal "bsfpjtc", Tower.parse(File.new("day7.input").each_line).root
  end
end

class TestPart2 < Minitest::Test
end

Minitest.autorun
