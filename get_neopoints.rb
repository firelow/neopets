#!/usr/bin/env ruby

require 'rubygems'
require 'watir-webdriver'
require 'watir-webdriver/wait'
require 'yaml'

config = {}
begin
  config_path = File.join(File.dirname(__FILE__), "config", "config.yml")
  config = YAML.load_file(config_path)
rescue Exception => e
  puts "Failed to parse config/config.yml file.  Does it exist?"
  puts e.inspect
  exit 1
end

require 'debugger' if config["debugger"]

USERNAME = config["np_user"]
PASSWORD = config["np_pass"]
NEOPET_NAME = config["np_name"]
NP_TO_KEEP = config["np_max_undeposited_pts"] # Maximum NP to leave undeposited
CLOSE_BROWSER = config["close_browser_on_exit"]

browser = Watir::Browser.new :chrome
jellyneoBrowser = Watir::Browser.new :chrome

begin
  # Login
  browser.goto 'http://www.neopets.com/login'
  browser.div(class: 'welcomeLoginUsernameInput').text_field.set USERNAME
  browser.div(class: 'welcomeLoginPasswordInput').text_field.set PASSWORD
  browser.button(class: 'welcomeLoginButton').click

  # Get free jelly
  browser.goto 'http://www.neopets.com/jelly/jelly.phtml'
  browser.button(value: 'Grab some Jelly').click

  # Collect bank interest
  browser.goto 'http://www.neopets.com/bank.phtml'
  if browser.td(class: 'contentModuleHeaderAlt').exist?
    browser.text_field(name: 'name').set config["np_user"]
    browser.text_field(name: 'add1').set '600 Cheshire Way'

    # current_employment = ['Chia Custodian', 'Wocky Warden', 'Korbat Keeper', 'Grarrl Guardian', 'JubJub Janitor', 'Lenny Librarian', 'Kiko Caretaker', 'Scorchio Supervisor', 'Pteri Policeman', 'Blumaroo Babysitter', 'Chomby Curator', 'Nimmo Nurse', 'Skeith Secretary', 'Aisha Assistant', 'Techo Technician', 'Gelert Gardener', 'Meerca Master', 'Elephante Editor', 'Quiggle Quantum Physicist', 'Other'].sample  
    # browser.select_list(name: 'salary').select 'Korbat Keeper'
    browser.execute_script("return $($('select')[0]).children()[3]")

    # annual_salary = ['10,000 NP and below', '10,000 to 25,000 NP', '25,001 to 40,000 NP', '40,001 to 60,000 NP', '60,001 to 90,000 NP', '90,001 to 120,000 NP', '120,001 NP and above'].sample
    # browser.select_list(name: 'employment').select '10,000 to 25,000 NP'

    account_number = (1..15).to_a.sample
    browser.select_list(name: 'account_type').option(value: '3')

    browser.text_field(name: 'initial_deposit').set 500
    browser.button(value: 'Sign Me Up').click
  else
    browser.button(value: /Collect Interest/).click
  end

  # Visit Coltzan's shrine
  browser.goto 'http://www.neopets.com/desert/shrine.phtml'
  browser.button(value: 'Approach the Shrine').click

  # Freebies (once a month)
  browser.goto 'http://www.neopets.com/freebies/index.phtml'

  # Get free omelette
  browser.goto 'http://www.neopets.com/prehistoric/omelette.phtml'
  omelette = browser.button(value: 'Grab some Omelette')
  omelette.click if omelette.exists?

  # Visit the Snowager
  browser.goto 'http://www.neopets.com/winter/snowager.phtml'
  snowager = browser.button(value: 'Attempt to steal a piece of treasure')
  snowager.click if snowager.exists?

  # Apple bobbing
  browser.goto 'http://www.neopets.com/halloween/applebobbing.phtml?bobbing=1'

  # Healing springs
  browser.goto 'http://www.neopets.com/faerieland/springs.phtml'
  springs = browser.button(value: 'Heal my Pets')
  springs.click if springs.exists?

  # Lab ray
  browser.goto 'http://www.neopets.com/lab2.phtml'
  browser.radio(value: NEOPET_NAME).click
  browser.button(value: 'Carry on with the Experiment!').click

  # Fruit machine
  browser.goto 'http://www.neopets.com/desert/fruit/index.phtml'
  browser.button(value: 'Spin, spin, spin!').click
  Watir::Wait.until { browser.div(id: 'fruitResult').visible? }

  # Solve the daily puzzle
  jellyneoBrowser.goto 'http://www.jellyneo.net/?go=dailypuzzle'
  answer = jellyneoBrowser.span(style: 'font-size:15px; font-weight:bold; color:blue').text
  browser.goto 'http://www.neopets.com/community/index.phtml'
  browser.select_list(name: 'trivia_response').select answer
  browser.button(class: 'medText submit').click

  # Faerie crossword. Solutions on cheat site look something like this:
  #
  # Across:
  # 1. soup
  # 3. mud
  # 5. toy
  # 6. exquisite
  # 7. pink
  # 8. mug
  # 10. oop
  # 11. web
  # 13. thade

  # Down:
  # 2. prigpants
  # 4. december
  # 5. tea
  # 9. gold
  # 10. one
  # 12. pad
  browser.goto 'http://www.neopets.com/games/crossword/crossword.phtml'
  jellyneoBrowser.goto 'http://www.jellyneo.net/?go=fcrossword'
  answers = jellyneoBrowser.div(class: 'article').text.split(/\n/)
  isAcross = true
  for answer in answers
    isAcross = false if /Down/.match(answer)
    tokenized = /(\d+)\. (.*)/.match(answer)
    next unless tokenized

    answerNumber = tokenized[1]
    answerPhrase = tokenized[2]

    # All 'across' links on the left, 'down' links on the right. If there are
    # two results and this is a down answer, click the second one.
    crosswordLinks = browser.links(text: /#{answerNumber}\. /)
    if crosswordLinks.length > 1 and not isAcross
      crosswordLinks[1].click
    else
      crosswordLinks[0].click
    end

    browser.text_field(name: 'x_word').set answerPhrase
    browser.button(value: 'Go').click
  end

  # Deposit NP into bank, leave some NP
  browser.goto 'http://www.neopets.com/bank.phtml'
  currentNP = Integer(browser.link(id: 'npanchor').text.gsub(',', ''))
  toDepositNP = currentNP - NP_TO_KEEP
  if toDepositNP > 0
    browser.text_field(name: 'amount').set toDepositNP
    browser.button(value: 'Deposit').click
    browser.alert.ok
  end
ensure
  jellyneoBrowser.close
  browser.close if CLOSE_BROWSER
end
