class Neopet

  attr_reader :browser

  def initialize browser
    @browser = Watir::Browser.new browser
    @browser.driver.manage.window.resize_to 1811,2000
  end

  def close
    @browser.close
  end

  def login
    @browser.goto 'http://www.neopets.com/login'
    @browser.div(class: 'welcomeLoginUsernameInput').text_field.set USERNAME
    @browser.div(class: 'welcomeLoginPasswordInput').text_field.set PASSWORD
    @browser.button(class: 'welcomeLoginButton').click
  end

  def get_jelly
    @browser.goto 'http://www.neopets.com/jelly/jelly.phtml'
    jelly = browser.button(value: 'Grab some Jelly')
    jelly.click if jelly.exist?
  end

  def go_to_bank
    @browser.goto 'http://www.neopets.com/bank.phtml'
    # Signup for Bank Account
    create_bank_account = @browser.td(class: 'contentModuleHeaderAlt', text: /Create a Bank Account/)    
    if create_bank_account.exists?
      @browser.text_field(name: 'name').set USERNAME
      @browser.text_field(name: 'add1').set '600 Cheshire Way'
      @browser.select_list(name: 'employment').select 'Korbat Keeper'
      @browser.select_list(name: 'salary').select '10,000 to 25,000 NP'
      @browser.select_list(name: 'account_type').select 'Neopian Student (min 1,000 NP)'
      @browser.text_field(name: 'initial_deposit').set 1100
      @browser.button(value: 'Sign Me Up').click
    else
      collect_interest = @browser.button(value: /Collect Interest/)
      collect_interest.click if collect_interest.exist?
    end
  end

  def go_to_shrine
    @browser.goto 'http://www.neopets.com/desert/shrine.phtml'
    approach_shrine = @browser.button(value: 'Approach the Shrine')
    approach_shrine.click if approach_shrine.exists?
  end

  def get_freebies
    @browser.goto 'http://www.neopets.com/freebies/index.phtml'
  end

  def get_omelette
    @browser.goto 'http://www.neopets.com/prehistoric/omelette.phtml'
    omelette = @browser.button(value: 'Grab some Omelette')
    omelette.click if omelette.exists?
  end

  def go_to_tombola
    @browser.goto 'http://www.neopets.com/island/tombola.phtml'
    tombola = @browser.button(value: 'Play Tombola!')
    tombola.click if tombola.exists?
  end

  def go_to_snowager
    @browser.goto 'http://www.neopets.com/winter/snowager.phtml'
    snowager = @browser.div(id: 'content').link(text: 'here')
    snowager.click if snowager.exists?
  end

  def go_applebobbing
    @browser.goto 'http://www.neopets.com/halloween/applebobbing.phtml?bobbing=1'
  end

  def go_to_springs
    @browser.goto 'http://www.neopets.com/faerieland/springs.phtml'
    springs = @browser.button(value: 'Heal my Pets')
    springs.click if springs.exists?
  end

  def go_to_lab
    @browser.goto 'http://www.neopets.com/lab2.phtml'
    neopet_name = @browser.radio(value: NEOPET_NAME)
    if neopet_name.exists?
       neopet_name.click
       @browser.button(value: 'Carry on with the Experiment!').click
    end
  end

  def play_fruit_machine
    @browser.goto 'http://www.neopets.com/desert/fruit/index.phtml'
    spin = @browser.button(value: 'Spin, spin, spin!')
    if spin.exists?
      @browser.button(value: 'Spin, spin, spin!').click
      Watir::Wait.until { @browser.div(id: 'fruitResult').visible? }
    end
  end

  def make_deposit
    @browser.goto 'http://www.neopets.com/bank.phtml'
    currentNP = Integer(@browser.link(id: 'npanchor').text.gsub(',', ''))
    toDepositNP = currentNP - NP_TO_KEEP      
      if toDepositNP > 0
        @browser.text_field(name: 'amount').set toDepositNP
        @browser.button(value: 'Deposit').click
        @browser.alert.ok
      end
  end

  def jellyneo(page)
      Nokogiri::HTML(open("http://www.jellyneo.net/?go=#{page}"))
  end

  def play_puzzle
    puzzlepage = jellyneo('dailypuzzle')
    answer = puzzlepage.xpath("//span[contains(@style, 'font-size:15px; font-weight:bold; color:blue')]").text
    @browser.goto 'http://www.neopets.com/community/index.phtml'

    select_list = @browser.select_list(name: 'trivia_response')
    if select_list.exists?
      select_list.select answer
      @browser.button(class: 'medText submit').click
    end

    # Faerie crossword. Solutions on cheat site look something like this:
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
    @browser.goto 'http://www.neopets.com/games/crossword/crossword.phtml'
    crosswordpage = jellyneo('fcrossword')
    answers = crosswordpage.css(".article").text.split(/\n/)
    isAcross = true
    for answer in answers
      isAcross = false if /Down/.match(answer)
      tokenized = /(\d+)\. (.*)/.match(answer)
      next unless tokenized
      answerNumber = tokenized[1]
      answerPhrase = tokenized[2]
      # All 'across' links on the left, 'down' links on the right. If there are
      # two results and this is a down answer, click the second one.
      crosswordLinks = @browser.links(text: /^#{answerNumber}\. /)
      if crosswordLinks.length > 1 and not isAcross
        crosswordLinks[1].click
      else
        crosswordLinks[0].click
      end
      @browser.text_field(name: 'x_word').set answerPhrase
      @browser.button(value: 'Go').click
    end		
  end
end
