struct IP
  def initialize(@characters : String)
  end

  def supports_tls?
    abbas_inside_hypernet, abbas_outside_hypernet = special_groups(4) { |(a, b, c, d)| a == d && b == c && a != b }.partition(&.hypernet)
    abbas_inside_hypernet.none? && abbas_outside_hypernet.any?
  end

  def supports_ssl?
    babs, abas = special_groups(3) { |(a, b, c)| a == c && a != b }.partition(&.hypernet)
    abas.any? { |aba| babs.any? { |bab| bab.characters == [aba.characters[1], aba.characters[0], aba.characters[1]] }}
  end

  private def special_groups(chars)
    inside_hypernet = false

    (0..@characters.size-chars)
      .map { |index|
        if @characters[index] == '['
          inside_hypernet = true; nil
        elsif @characters[index] == ']'
          inside_hypernet = false; nil
        elsif yield(@characters.chars[index..index+chars-1])
          SpecialGrouping.new(@characters.chars[index..index+chars-1], inside_hypernet)
        end
      }.compact
  end

  struct SpecialGrouping
    getter characters, hypernet

    def initialize(@characters : Array(Char), @hypernet : Bool)
    end
  end
end

require "spec"

describe "Day 7" do
  it "concludes abba[mnop]qrst supports TLS" do
    IP.new("abba[mnop]qrst").supports_tls?.should eq(true)
  end

  it "concludes abcd[bddb]xyyx does not support TLS" do
    IP.new("abcd[bddb]xyyx").supports_tls?.should eq(false)
  end

  it "concludes aaaa[qwer]tyui does not support TLS" do
    IP.new("aaaa[qwer]tyui").supports_tls?.should eq(false)
  end

  it "concludes ioxxoj[asdfgh]zxcvbn supports TLS" do
    IP.new("ioxxoj[asdfgh]zxcvbn").supports_tls?.should eq(true)
  end

  it "counts the number of IPs that support TLS in the challenge input" do
    File
      .each_line("day7.input")
      .map { |c| IP.new(c) }
      .count(&.supports_tls?)
      .should eq(110)
  end

  it "concludes aba[bab]xyz supports SSL" do
    IP.new("aba[bab]xyz").supports_ssl?.should eq(true)
  end

  it "concludes xyx[xyx]xyx does not support SSL" do
    IP.new("xyx[xyx]xyx").supports_ssl?.should eq(false)
  end

  it "concludes aaa[kek]eke supports SSL" do
    IP.new("aaa[kek]eke").supports_ssl?.should eq(true)
  end

  it "concludes zazbz[bzb]cdb supports SSL" do
    IP.new("zazbz[bzb]cdb").supports_ssl?.should eq(true)
  end

  it "counts the number of IPs that support SSL in the challenge input" do
    File
      .each_line("day7.input")
      .map { |c| IP.new(c) }
      .count(&.supports_ssl?)
      .should eq(242)
  end
end
