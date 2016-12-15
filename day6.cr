require "spec"

module Day6
  alias Strategy = Array({Char, UInt32}) -> {Char, UInt32}
  MOST_COMMON = Strategy.new(&.last)
  LEAST_COMMON = Strategy.new(&.first)

  def self.receive(strategy : Strategy, messages : String)
    messages
      .strip
      .split("\n")
      .map(&.chars)
      .transpose
      .map { |chars| chars.each_with_object(Hash(Char, UInt32).new(0_u32)) { |char, counts| counts[char] += 1 } }
      .map(&.to_a)
      .map(&.sort_by(&.last))
      .map(&strategy)
      .map(&.first)
      .join
  end
end

describe "Day 6" do
  it "error corrects the sample messages" do
    Day6
      .receive(
        Day6::MOST_COMMON,
        "eedadn\ndrvtee\neandsr\nraavrd\natevrs\ntsrnev\nsdttsa\nrasrtv\nnssdts\nntnada\nsvetve\ntesnvt\nvntsnd\nvrdear\ndvrsen\nenarar"
      )
      .should eq("easter")
  end

  it "error corrects the challenge message" do
    Day6.receive(Day6::MOST_COMMON, File.read("day6.input")).should eq("kqsdmzft")
  end

  it "modified error corrects the sample messages" do
    Day6
      .receive(
        Day6::LEAST_COMMON,
        "eedadn\ndrvtee\neandsr\nraavrd\natevrs\ntsrnev\nsdttsa\nrasrtv\nnssdts\nntnada\nsvetve\ntesnvt\nvntsnd\nvrdear\ndvrsen\nenarar"
      )
      .should eq("advent")
  end

  it "modified error corrects the challenge message" do
    Day6.receive(Day6::LEAST_COMMON, File.read("day6.input")).should eq("tpooccyo")
  end
end
