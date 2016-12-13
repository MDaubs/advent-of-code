require "crypto/md5"
require "spec"

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

def decode_v3(door_id : String)
  concurrency = 4
  password = ""

  Crypto::MD5.hex_digest do |context|
    context.update(door_id)
    matches = Channel({Char, Int32}).new

    concurrency.times do |fiber_index|
      spawn do
        index = fiber_index

        while
          context_copy = context.dup
          context_copy.update(index.to_s)
          context_copy.final
          hash = context_copy.hex

          if hash[0..4] == "00000"
            puts "#{fiber_index} Found #{hash} at #{index}"
            matches.send({hash[5], index})
            index += concurrency
            break
          else
            puts "#{fiber_index} Scan #{index}" if index % 100_000 == 0
            index += concurrency
          end
        end
      end
    end

    results = [] of {Char, Int32}

    8.times do
      results << matches.receive
    end

    password = results.sort_by(&.last).first(8).join
  end

  password
end

describe "Day 5" do
  it "determines the password for door abc is 18f47a30" do
    decode_v2("abc").should eq("18f47a30")
  end

  it "determines the password for door cxdnnyjw" do
    decode_v2("cxdnnyjw").should eq("something")
  end
end
