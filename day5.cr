require "crypto/md5"
require "socket"
require "spec"

# VERSION 1
# Simple solution, approximately 1:14 for sample decode.
def decode_v1(door_id : String)
  hash = ""
  index = 0
  password = ""

  8.times do
    while
      hash = Crypto::MD5.hex_digest("#{door_id}#{index}")

      if hash[0..4] == "00000"
        puts "Found #{hash} at #{index}"
        index += 1
        break
      else
        puts "Scan #{index}" if index % 100_000 == 0
        index += 1
      end
    end

    password += hash[5]
  end

  password
end

# VERSION 2
# Don't repeatly hash door_id portion, approximately 0:59 for sample decode.
def decode_v2(door_id : String)
  hash = ""
  index = 0
  password = ""

  Crypto::MD5.hex_digest do |context|
    context.update(door_id)

    8.times do
      while
        context_copy = context.dup
        context_copy.update(index.to_s)
        context_copy.final
        hash = context_copy.hex

        if hash[0..4] == "00000"
          puts "Found #{hash} at #{index}"
          index += 1
          break
        else
          puts "Scan #{index}" if index % 100_000 == 0
          index += 1
        end
      end

      password += hash[5]
    end
  end

  password
end

# VERSION 3
# V2 optimization + hash on four cores concurrently.
# Approximately 0:24 for sample decode.

class HashingProcess
  getter index, process

  @client : UNIXSocket
  @server : UNIXSocket
  @process : Process?

  def initialize(@id : Int32, @increment : Int32, @door_id : String)
    @server, @client = UNIXSocket.pair
    @index = @id
  end

  def start(channel : Channel({Char, Int32}))
    @process = fork { hash_loop }

    spawn do
      @server.each_line do |line|
        if line.starts_with?("found")
          _, char, index = line.split(":")
          channel.send({char[0], index.to_i})
        elsif line.starts_with?("index")
          @index = line.split(":").last.not_nil!.to_i
        end
      end
    end
  end

  def kill
    @process.not_nil!.kill
  end

  private def hash_loop
    Crypto::MD5.hex_digest do |md5_context|
      md5_context.update(@door_id)

      while
        md5_context_copy = md5_context.dup
        md5_context_copy.update(@index.to_s)
        md5_context_copy.final
        hash = md5_context_copy.hex

        if hash[0..4] == "00000"
          @client.puts "found:#{hash[5]}:#{index}"
        elsif @index % 10_000 == @id
          @client.puts "index:#{index}"
        end

        @index += @increment
      end
    end
  end
end

def decode_v3(door_id : String)
  channel = Channel({Char, Int32}).new
  concurrency = 4
  password = ""
  results = [] of {Char, Int32}
  workers = concurrency
    .times
    .map { |i| HashingProcess.new(i, concurrency, door_id) }
    .to_a

  workers.each(&.start(channel))

  while
    results << channel.receive
    results.sort_by!(&.last)

    if results.size >= 8 && results.map(&.last)[7] < workers.not_nil!.map(&.index).min
      workers.each(&.kill)
      password = results.first(8).map(&.first).join
      break
    end
  end

  password
end

describe "Day 5" do
  it "determines the password for door abc is 18f47a30" do
    decode_v3("abc").should eq("18f47a30")
  end

  it "determines the password for door cxdnnyjw" do
    decode_v3("cxdnnyjw").should eq("f77a0e6e")
  end
end
