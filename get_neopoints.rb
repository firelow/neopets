#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
Bundler.setup
require 'nokogiri'
require 'open-uri'
require_relative 'init'
require_relative 'neopet'

neopet = Neopet.new :chrome

begin
  # Login
  neopet.login

  # Get free jelly
  neopet.get_jelly
  puts "Gots mah jelly"

  # Collect bank interest
  neopet.go_to_bank
  puts "Got some Monies"

  # Visit Coltzan's shrine
  neopet.go_to_shrine
  puts "Visited shrine"

  # Freebies (once a month)
  neopet.get_freebies
  puts "Got mah freebies"

  # Get free omelette
  neopet.get_omelette
  puts "Ate some omelette! yum!"

  # Tombola
  neopet.go_to_tombola
  puts "Visited Tombola"

  # Visit the Snowager
  neopet.go_to_snowager
  puts "Visited Snowager"

  # Apple bobbing
  neopet.go_applebobbing
  puts "Went applebobbing"

  # Healing springs
  neopet.go_to_springs
  puts "Visited Healing Springs"

  # Lab ray
  neopet.go_to_lab
  puts "Went to lab"

  # Fruit machine
  neopet.play_fruit_machine
  puts "Played fruit machine"

  # Solve the daily puzzle
  neopet.play_puzzle
  puts "Puzzle solved!"

  # Deposit NP into bank, leave some NP
  neopet.make_deposit
  puts "Deposited Monies!"
ensure
  neopet.close if CLOSE_BROWSER
end
