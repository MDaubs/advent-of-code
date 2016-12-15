require "spec"

module Day6
  def self.receive(messages : String)
    messages.strip.split("\n").map(&.chars).transpose.map(&->most_common(Array(Char))).join
  end

  private def self.most_common(chars : Array(Char))
    chars
      .each_with_object(Hash(Char, UInt32).new(0_u32)) { |char, counts| counts[char] += 1 }
      .to_a.sort_by(&.last).last.first
  end
end

describe "Day 6" do
  it "error corrects the sample messages" do
    Day6
      .receive("eedadn\ndrvtee\neandsr\nraavrd\natevrs\ntsrnev\nsdttsa\nrasrtv\nnssdts\nntnada\nsvetve\ntesnvt\nvntsnd\nvrdear\ndvrsen\nenarar")
      .should eq("easter")
  end

  it "error corrects the challenge message" do
    Day6.receive(File.read("day6.input")).should eq("kqsdmzft")
  end
end
