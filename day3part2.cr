alias CandidateTriangleLengths = Array(UInt32)

def parse_horizontal(candidates : String) : Array(CandidateTriangleLengths)
  candidates
    .strip                # Remove newline not preceeding candidate lengths
    .split("\n")          # Divide input into one string per line
    .each                 # Modify lines without creating intermediate arrays
    .map(&.strip)         # Strip each line of leading and trailing whitespace
    .map(&.split(/\s+/))  # Divide line into lengths separated by 1+ whitespace
    .map(&.map(&.to_u32)) # Convert each length to an unsigned integer
    .to_a                 # Perform the parse
end

def parse_vertical(candidates : String) : Array(CandidateTriangleLengths)
  parse_horizontal(candidates)
    .each_slice(3)        # For each slice of three lines
    .flat_map { |lines|   # Map columns of integers to candidate lengths
      [
        [lines[0][0], lines[1][0], lines[2][0]],
        [lines[0][1], lines[1][1], lines[2][1]],
        [lines[0][2], lines[1][2], lines[2][2]]
      ]
    }
end

def check(candidate : CandidateTriangleLengths) : Bool
  sum_of_all_lengths = candidate.sum
  candidate.all? { |length| length < sum_of_all_lengths - length }
end

require "spec"

describe "Day 3" do
  it "determines that 5 10 25 is not a triangle" do
    parse_horizontal("  5  10  25 ")
      .map(&->check(CandidateTriangleLengths))
      .should eq([false])
  end

  it "determines that 10 15 10 is a triangle" do
    parse_horizontal(" 10  15  10 ")
      .map(&->check(CandidateTriangleLengths))
      .should eq([true])
  end

  it "determines the correct count for the challenge input" do
    parse_horizontal(File.read("day3.input"))
      .count(&->check(CandidateTriangleLengths))
      .should eq(869)
  end

  it "determines triangles when lengths are supplied in vertical triples" do
    input = %{
      101 301 501
      102 302 502
      103 303 503
      201 401 601
      202 402 602
      203 403 603
    }

    parse_vertical(input)
      .count(&->check(CandidateTriangleLengths))
      .should eq(6)
  end

  it "determines the correct count for the challenge input parsed vertically" do
    parse_vertical(File.read("day3.input"))
      .count(&->check(CandidateTriangleLengths))
      .should eq(1544)
  end
end
