alias CandidateTriangleLengths = Array(UInt32)

def parse(candidates : String) : Array(CandidateTriangleLengths)
  candidates
    .strip                # Remove newline not preceeding candidate lengths
    .split("\n")          # Divide input into one string per line
    .each                 # Modify lines without creating intermediate arrays
    .map(&.strip)         # Strip each line of leading and trailing whitespace
    .map(&.split(/\s+/))  # Divide line into lengths separated by 1+ whitespace
    .map(&.map(&.to_u32)) # Convert each length to an unsigned integer
    .to_a                 # Perform the parse
end

def check(candidate : CandidateTriangleLengths) : Bool
  sum_of_all_lengths = candidate.sum
  candidate.all? { |length| length < sum_of_all_lengths - length }
end

require "spec"

describe "Day 3" do
  it "determines that 5 10 25 is not a triangle" do
    parse("  5  10  25 ")
      .map(&->check(CandidateTriangleLengths))
      .should eq([false])
  end

  it "determines that 10 15 10 is a triangle" do
    parse(" 10  15  10 ")
      .map(&->check(CandidateTriangleLengths))
      .should eq([true])
  end

  it "determines the correct count for the challenge input" do
    parse(File.read("day3.input"))
      .count(&->check(CandidateTriangleLengths))
      .should eq(869)
  end
end
