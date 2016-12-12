require "spec"
require "string_scanner"

struct EncryptedRoomEntry
  @encrypted_name : String
  @sector_id : UInt32
  @checksum : String

  getter sector_id

  def initialize(@encrypted_name, @sector_id, @checksum)
  end

  def real?
    @checksum == letter_counts
      .to_a
      .sort { |(letter1, _), (letter2, _)| letter1 <=> letter2 }
      .sort { |(_, count1), (_, count2)| -1 * (count1 <=> count2) }
      .first(5)
      .map(&.first)
      .join
  end

  private def letter_counts
    @encrypted_name.each_char.reduce({} of Char => UInt32) { |counts, letter|
      if letter != '-'
        counts[letter] ||= 0.to_u32
        counts[letter] += 1.to_u32
      end

      counts
    }
  end
end

class EncryptedListOfRooms
  include Iterator(EncryptedRoomEntry)

  @line_iterator : Iterator(String)

  def initialize(@encrypted_rooms : String)
    @line_iterator = @encrypted_rooms.strip.each_line
  end

  def next : Stop | EncryptedRoomEntry
    next_line = @line_iterator.next

    if next_line == stop
      stop
    elsif matches = /([a-z\-]+)(?:\-)(\d+)(?:\[)([a-z]{5})(?:\])/.match(next_line.as(String))
      EncryptedRoomEntry.new(matches[1], matches[2].to_u32, matches[3])
    else
      raise "Unable to parse line '{next_line}'."
    end
  end
end

describe "Day 4" do
  it "sums the first three sector IDs of the sample rooms" do
    input = %{
      aaaaa-bbb-z-y-x-123[abxyz]
      a-b-c-d-e-f-g-h-987[abcde]
      not-a-real-room-404[oarel]
      totally-real-room-200[decoy]
    }

    EncryptedListOfRooms.new(input).select(&.real?).map(&.sector_id).sum.should eq(1514)
  end
end
