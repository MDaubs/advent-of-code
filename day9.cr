require "string_scanner"
require "spec"

class Decompress
  def self.string(input)
    String.build do |output|
      new(input.strip.gsub(/\s/, "")).decompress(output)
    end
  end

  def self.length(input)
    Counter.count do |counter|
      new(input.strip.gsub(/\s/, "")).decompress(counter)
    end
  end

  def initialize(@input : String)
    @scanner = StringScanner.new(@input)
  end

  def decompress(output : IO | Counter)
    until @scanner.eos?
      if marker = @scanner.scan(/\((\d+)x(\d+)\)/)
        marker =~ /\((\d+)x(\d+)\)/
        chars_to_repeat = @scanner.scan(/.{#{$~[1]}}/)
        $~[2].to_i.times { output << chars_to_repeat }
      else
        output << @scanner.scan(/./)
      end
    end
  end
end

class Counter
  getter length

  @length = 0_u32

  def self.count
    new.tap do |counter|
      yield counter
    end.length
  end

  def <<(input)
    if input
      @length += input.size
    end
  end
end

class Decompress2
  abstract class Node
    abstract def eval : UInt64

    class Char < Node
      def initialize(@char : ::Char)
      end

      def eval
        1.to_u64
      end
    end

    class Marker < Node
      @nodes : Array(Node)

      def initialize(input : String, @repeat_times : UInt32)
        @nodes = Parser.new(input).nodes
      end

      def eval
        @nodes.sum(&.eval) * @repeat_times
      end
    end
  end

  def self.length(input)
    Parser.new(input).eval
  end

  class Parser
    getter nodes

    @nodes : Array(Node)

    def initialize(@input : String)
      @scanner = StringScanner.new(@input)
      @nodes = Array(Node).new.tap do |nodes|
        until @scanner.eos?
          if marker = @scanner.scan(/\((\d+)x(\d+)\)/)
            marker =~ /\((\d+)x(\d+)\)/
            repeated_section = @scanner.scan(/.{#{$~[1]}}/)
            repeat_times = $~[2].to_u32
            nodes << Node::Marker.new(repeated_section.not_nil!, repeat_times)
          else
            nodes << Node::Char.new(@scanner.scan(/./).not_nil![0])
          end
        end
      end
    end

    def eval
      nodes.sum(&.eval)
    end
  end
end

describe "Day 9 Part 1" do
  it "decompresses ADVENT" do
    Decompress.string("ADVENT").should eq("ADVENT")
  end

  it "decompresses A(1x5)BC" do
    Decompress.string("A(1x5)BC").should eq("ABBBBBC")
  end

  it "decompresses (3x3)XYZ" do
    Decompress.string("(3x3)XYZ").should eq("XYZXYZXYZ")
  end

  it "decompresses A(2x2)BCD(2x2)EFG" do
    Decompress.string("A(2x2)BCD(2x2)EFG").should eq("ABCBCDEFEFG")
  end

  it "decompresses (6x1)(1x3)A" do
    Decompress.string("(6x1)(1x3)A").should eq("(1x3)A")
  end

  it "decompresses X(8x2)(3x3)ABCY" do
    Decompress.string("X(8x2)(3x3)ABCY").should eq("X(3x3)ABC(3x3)ABCY")
  end

  it "decompresses the challenge input" do
    Decompress.string(File.read("day9.input")).size.should eq(110346)
  end

  it "counts the decompressed challenge input" do
    Decompress.length(File.read("day9.input")).should eq(110346)
  end
end

describe "Day 9 Part 2" do
  it "counts the decompressed sample X(8x2)(3x3)ABCY" do
    Decompress2.length("X(8x2)(3x3)ABCY").should eq("XABCABCABCABCABCABCY".size)
  end

  it "counts the decompressed sample (27x12)(20x12)(13x14)(7x10)(1x12)A" do
    Decompress2.length("(27x12)(20x12)(13x14)(7x10)(1x12)A").should eq(241920)
  end

  it "counts the decompressed sample (25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN" do
    Decompress2.length("(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN").should eq(445)
  end

  it "counts the decompressed challenge input" do
    Decompress2.length(File.read("day9.input").strip).should eq(10774309173)
  end
end
