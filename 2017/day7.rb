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

    root_name = (program_weights.keys - program_parents.keys).first

    Tower.build(root_name, program_weights, program_parents)
  end

  def self.build(name, weights, parents)
    children = parents
      .select { |_, parent| parent == name }
      .map { |child_name, _| build(child_name, weights, parents) }

    Tower.new(name, weights[name].to_i, children)
  end

  attr_reader :name, :children

  def initialize(name, weight, children)
    @name = name
    @weight = weight
    @children = children
  end

  def solo_weight
    @weight
  end

  def weight
    @weight + children.map(&:weight).sum
  end

  def unbalanced
    if @children.map(&:weight).uniq.size > 1
      self
    else
      @children.find(&:unbalanced)
    end
  end
end

INPUT = [
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

class TestPart1 < Minitest::Test
  def test_example_input
    assert_equal "tknk", Tower.parse(INPUT).name
  end

  def test_challenge_input
    assert_equal "bsfpjtc", Tower.parse(File.new("day7.input").each_line).name
  end
end

class TestPart2 < Minitest::Test
  # ugml + (gyxo + ebii + jptl) = 68 + (61 + 61 + 61) = 251
  def test_example_weight_ugml
    assert_equal 251, Tower.parse(INPUT).children.find { |c| c.name == "ugml" }.weight
  end

  # padx + (pbga + havc + qoyq) = 45 + (66 + 66 + 66) = 243
  def test_example_weight_padx
    assert_equal 243, Tower.parse(INPUT).children.find { |c| c.name == "padx" }.weight
  end

  # fwft + (ktlj + cntj + xhth) = 72 + (57 + 57 + 57) = 243
  def test_example_weight_fwft
    assert_equal 243, Tower.parse(INPUT).children.find { |c| c.name == "fwft" }.weight
  end

  # As you can see, tknk's disc is unbalanced: ugml's stack is heavier than the other two. Even though the nodes above ugml are balanced, ugml itself is too heavy: it needs to be 8 units lighter for its stack to weigh 243 and keep the towers balanced. If this change were made, its weight would be 60.
  def test_example_unbalanced
    assert_equal "tknk", Tower.parse(INPUT).unbalanced.name
  end

  def test_challenge_input
    unbalanced = Tower.parse(File.new("day7.input").each_line).unbalanced
    minority_weight, majority_weight = unbalanced.children.map(&:weight).group_by(&:itself).sort_by { |a, b| b.size }.map(&:first)
    unbalanced_cause = unbalanced.children.find { |child| child.weight == minority_weight }
    new_weight = unbalanced_cause.solo_weight + majority_weight - minority_weight


    assert_equal 60, new_weight
  end
end

Minitest.autorun
