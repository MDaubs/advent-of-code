require "openssl"
require "spec"

module Day5
  alias DecryptedChar = {Char, UInt32}
  alias SpecialHash = {String, UInt32}

  def self.decrypt(crypted : String)
    SpecialHashes.new(crypted).first(8).map { |(hash, index)| {hash[5], index} }.to_a.map(&.first).join
  end

  class SpecialHashes
    include Iterator(SpecialHash)

    @index = 0_u32

    def initialize(@prefix : String)
    end

    def next
      while
        hash = OpenSSL::MD5.hash("#{@prefix}#{@index}").to_slice.hexstring
        @index += 1
        return {hash, @index - 1} if hash.starts_with?("00000")
        raise "Gave up searching" if @index == 10_000_000
      end

      raise "This should never happen but the compiler needs to be assured we can't return nil."
    end
  end
end

describe "Day 5" do
  it "determines the password for door abc is 18f47a30" do
    Day5.decrypt("abc").should eq("18f47a30")
  end

  it "determines the password for door cxdnnyjw" do
    Day5.decrypt("cxdnnyjw").should eq("f77a0e6e")
  end
end
