require 'selenium-webdriver'
require 'pp'
require 'colorize'

require "./config.rb"
# @userId=""
# @passwd=""
# @memInfo=""
# @bitbargain_username=""

def createDriver
	Selenium::WebDriver.for :chrome
end

def setSelected selectId, value
	select = Selenium::WebDriver::Support::Select.new @driver.find_element(:id => selectId)
	select.select_by :value, value
end

def click elementId
	@driver.find_element(:id => elementId).click
	sleep 1
end

def login
	@driver.get "https://online.lloydsbank.co.uk/personal/logon/login.jsp"
	@driver.find_element(:id => "frmLogin:strCustomerLogin_userID").send_keys @userId
	@driver.find_element(:id => "frmLogin:strCustomerLogin_pwd").send_keys @passwd
	click "frmLogin:btnLogin2"
end

def enterMemorableInfo
	for i in 1..3
		selectId = "frmentermemorableinformation1:strEnterMemorableInformation_memInfo#{i}"
		label = @driver.find_element :xpath => "//label[@for='#{selectId}']"
		index = label.text.gsub(/Character/, '').gsub(/:/, '').strip.to_f
		setSelected selectId, "&nbsp;#{@memInfo[index-1]}"
	end
	click "frmentermemorableinformation1:btnContinue"
end

def openAccount index
	@driver.get "https://secure.lloydsbank.co.uk/personal/a/account_details_ress"
	account = @driver.find_element :id => "lnkAccName_des-m-sat-xx-#{index}"
	accountName = account.text
	click "lnkAccName_des-m-sat-xx-#{index}"
	accountName
end

def getRowsOnScreen
	sleep 1
	table = @driver.find_element :css => "tbody.cwa-tbody"
	rows = table.find_elements :css => "tr"

	rowVals = []
	skip = true
	rows.each do |row|
		rowElements = row.find_elements :css => "td"
		rowContent = {}
		begin
			rowContent = {
				:date => rowElements[1].text.split("\n")[0],
				:name => rowElements[1].text.split("\n")[1],
				:xfer_type => rowElements[2].text,
				:money_in => rowElements[3].text,
				:money_out => rowElements[4].text,
				:balance => rowElements[5].text,
			}
			
		rescue Exception => e
			next
		end
		rowVals.push rowContent unless rowContent[:money_out].to_f > 0
	end

	return rowVals
end

def printTransactions
	openAccount 1
	
	rowVals = getRowsOnScreen
	clearScreen
	sleep 0.3
	puts "Latest bank deposits:"
	puts ""
	rowVals.each do |row|
		sleep 0.01
		puts " £#{row[:money_in].ljust(8," ")} - #{row[:name]}"
	end
	@driver.find_element(:css=>"a.back-to-accounts-btn").click
end

def checkCheapest
	cheapestCount = 15
	puts ""
	puts "#{cheapestCount} Cheapest BitBargain sellers:"
	@driver2.get 'https://bitbargain.co.uk/buy'
	rowElements = @driver2.find_elements :css => "div.container table.table-striped > tbody > tr:nth-child(-n+#{cheapestCount})"

	rowData = []
	rowElements.each do |row|
		cells = row.find_elements :css => "td"
		begin
			data = {
				:seller => cells[0].text,
				:item => cells[1].text,
				:payment => cells[2].text,
				:minimum => cells[3].text,
				:unit => cells[4].text,
				:price => cells[5].text,
				:action => cells[6].text,
			}
		rescue
			next
		end
		rowData.push data
	end

	puts ""
	lowest_price = 0
	lowest_price_sellers = []
	all_sellers = []
	rowData.each do |data|
		next if data[:action].downcase == "offline"
		lowest_price = data[:unit] if lowest_price == 0
		lowest_price_sellers.push(data[:seller].downcase) if lowest_price == data[:unit]
		all_sellers.push(data[:seller].downcase)
		sleep 0.01
		puts " #{data[:unit].gsub(" ","")} - #{data[:seller]}"
	end

	puts ""

	lowest_price_sellers.uniq!

	if lowest_price_sellers.include? @bitbargain_username.downcase
		if lowest_price_sellers.size == 1
			puts "You are the cheapest!".white.on_green
		else
			puts "You are joint cheapest".white.on_yellow
		end
	else
		puts "You are not the cheapest!".white.on_red
		puts ""
		if all_sellers.include? @bitbargain_username.downcase
			puts "But you are in the top #{cheapestCount}".white.on_yellow
		else
			puts "You aren't even in the top #{cheapestCount}!".white.on_red
		end
	end

	puts ""
end

def clearScreen
	system "clear" or system "cls"
end

def countdown wait_for 
	waited = 0
	yield
	loop do
		sleep 2
		if (waited >= wait_for)
			print "Refreshing now..."
			yield
			waited = 0
			next
		else
			print "#{wait_for - waited} "
		end
		waited += 1
	end
end

loop do
	begin
		@driver2 = createDriver
		@driver = createDriver
		login
		enterMemorableInfo
		clearScreen
		countdown 5 do
			printTransactions
			checkCheapest
		end
	rescue StandardError => e
		# puts e.full_message(highlight: true, order: :top)
		# break
		clearScreen
		puts "An error occurred. Restarting script...".white.on_red
	ensure
		@driver.quit if @driver != nil
		@driver2.quit if @driver2 != nil
	end
end
