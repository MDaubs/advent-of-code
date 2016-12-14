require "openssl"
require "spec"

module Day5
  def self.decrypt(crypted : String)
    SpecialHashes.new(crypted).first(8).map(&.[5]).join
  end

  def self.decrypt2(crypted : String)
    results = StaticArray(Char?, 8).new(nil)

    SpecialHashes
      .new(crypted)
      .take_while { results.any?(&.nil?) }
      .select { |hash| ('0'..'7').includes?(hash[5]) }
      .each { |hash| results[hash[5].to_u32] ||= hash[6] }

    results.map(&.not_nil!).join
  end

  class SpecialHashes
    include Iterator(String)

    @index = 0_u32

    def initialize(@prefix : String)
    end

    def next
      while
        hash = OpenSSL::MD5.hash("#{@prefix}#{@index}").to_slice.hexstring
        @index += 1
        return hash if hash.starts_with?("00000")
        raise "Gave up searching" if @index == 100_000_000
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

  it "determines the password for the second door abc is 05ace8e3" do
    Day5.decrypt2("abc").should eq("05ace8e3")
  end

  it "determines the password for the second door cxdnnyjw is something" do
    Day5.decrypt2("cxdnnyjw").should eq("999828ec")
  end
end
