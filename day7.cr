struct IP
  def initialize(@characters : String)
  end

  def supports_tls?
    abbas_inside_hypernet, abbas_outside_hypernet = abbas.partition(&.hypernet)
    abbas_inside_hypernet.none? && abbas_outside_hypernet.any?
  end

  private def abbas
    inside_hypernet = false

    (0..@characters.size-5).map { |index|
      a, b, c, d = @characters[index..index+4]

      if a == '['
        inside_hypernet = true; nil
      elsif a == ']'
        inside_hypernet = false; nil
      elsif a == d && b == c && a != b
        ABBA.new(hypernet: inside_hypernet)
      end
    }.compact
  end

  struct ABBA
    getter hypernet

    def initialize(@hypernet : Bool)
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
end
