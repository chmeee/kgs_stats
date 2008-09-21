#!/usr/bin/env ruby

# Required libs/gems
require 'rubygems'
require 'net/http'
require 'zipruby'
require 'optparse'

# Initial counters
count = 0
won   = 0
jigo  = 0

# Player, board and month information
player  = "chmeee"
board   = "19"
month   = "#{Time.now.year}-#{Time.now.month}"

# Options
opts = OptionParser.new do |opts|
  opts.on("-p [string]", "KGS name for player") do |p|
    player = p
  end
  opts.on("-b [string]", "Board size (default = 19)") do |b|
    board = b
  end
  opts.on("-m [string]", "Month we want the stats for (default = current month)") do |m|
    month = m
  end
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end
opts.parse!(ARGV)

# Get the file from gokgs.com
Net::HTTP.start("www.gokgs.com") do |http|
  zip = http.get("/servlet/archives/en_US/#{player}-#{month}.zip")
  Zip::Archive.open_buffer(zip.body) do |arch|
    arch.each do |file|
      game = file.read
      game.match('SZ\[(\d*)\]')
      white = black = nil
      if $1 == board
        game.each do |line|
          if line =~ /PW\[(\w*)\]/
            white = $1
          end
          if line =~ /PB\[(\w*)\]/
            black = $1
          end
          if line =~ /RE\[(.*)\]/
            res = $1
            won += 1 if (res =~ /^W/ and white == player) or (res =~ /^B/ and black == player)
            jigo += 1 if (res == '0')
            count += 1
            break
          end
        end
      end
    end
  end
end

puts ":: KGS stats for #{player} ::"
puts "Total\t= #{count}"
puts "Won\t= #{won}"
puts "Jigo\t= #{jigo}"
printf("%% won\t= %.2f %%\n", count != 0 ? won.to_f*100/count : 0)
