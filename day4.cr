require "spec"
require "string_scanner"

struct EncryptedRoomEntry
  @encrypted_name : String
  @sector_id : UInt32
  @checksum : String

  ALPHABET = ('a'..'z').to_a

  getter sector_id

  def initialize(@encrypted_name, @sector_id, @checksum)
  end

  def name
    shifted_alphabet = ALPHABET.rotate(@sector_id.to_i % 26)

    @encrypted_name
      .each_char
      .map { |char| char == '-' ? ' ' : shifted_alphabet[char.ord - 97] }
      .join
  end

  def real?
    @checksum == calculated_checksum
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

  private def calculated_checksum
    letter_counts
      .to_a
      .sort { |(let1, cnt1), (let2, cnt2)| cnt1 == cnt2 ? let1 <=> let2 : -1 * (cnt1 <=> cnt2) }
      .first(5)
      .map(&.first)
      .join
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

  it "sums the first challenge input" do
    EncryptedListOfRooms.new(File.read("day4.input")).select(&.real?).map(&.sector_id).sum.should eq(137896)
  end

  it "decodes the sample name" do
    EncryptedListOfRooms.new("qzmt-zixmtkozy-ivhz-343[abcde]").first.name.should eq("very encrypted name")
  end

  it "returns the sector id of the North Pole" do
    EncryptedListOfRooms
      .new(File.read("day4.input"))
      .select(&.real?)
      .find { |room| room.name == "northpole object storage" }
      .not_nil!
      .sector_id
      .should eq(501)
  end
end
