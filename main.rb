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
	table = @driver.find_element :css => "tbody.cwa-tbody"
	rows = table.find_elements :css => "tr"

	rowVals = []
	skip = true
	rows.each do |row|
		rowElements = row.find_elements :css => "td"
		rowContent = {}
		begin
			rowContent = {
				:date => rowElements[0].text,
				:name => rowElements[1].text,
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
	puts "Most recent bank deposits:"
	
	puts ""
	rowVals.each do |row|
		sleep 0.01
		puts "Received  #{row[:money_in].ljust(8," ")}  from  '#{row[:name]}'"
	end
	@driver.find_element(:css=>"a.back-to-accounts-btn").click
end

def checkCheapest
	puts ""
	puts "Cheapest BitBargain sellers:"
	@driver2.get 'https://bitbargain.co.uk/buy'
	rowElements = @driver2.find_elements :css => "div.container table.table-striped > tbody > tr:nth-child(-n+10)"

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
			}
		rescue
			next
		end
		rowData.push data
	end

	puts ""
	cheapest = 0
	cheap_sellers = []
	rowData.each do |data|
		cheapest = data[:unit] if cheapest == 0
		cheap_sellers.push(data[:seller].downcase) if cheapest == data[:unit]
		sleep 0.01
		puts "#{data[:unit].gsub(" ","")} - #{data[:seller]}"
	end

	puts ""

	cheap_sellers.uniq!

	if cheap_sellers.include? @bitbargain_username.downcase
		if cheap_sellers.size == 1
			puts "You are the cheapest!".white.on_green
		else
			puts "You are joint cheapest".white.on_yellow
		end
	else
		puts "You are not the cheapest!".white.on_red
	end

	puts ""
end

def clearScreen
	system "clear" or system "cls"
end

def repeat 
	wait_for = 5
	waited = 0
	yield
	loop do
		sleep 2
		if (waited >= wait_for)
			print "Refreshing now..."
			begin
				yield
			rescue Exception => e
				puts "Error"
				puts e
			end
			waited = 0
			next
		else
			print "#{wait_for - waited} "
		end
		waited += 1
	end
end

begin
	clearScreen
	@driver2 = createDriver
	@driver = createDriver
	login
	enterMemorableInfo
	
		
	repeat do
		printTransactions
		checkCheapest
	end
ensure
	@driver.quit if @driver != nil
	@driver2.quit if @driver2 != nil
end
