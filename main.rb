require 'selenium-webdriver'
require 'pp'

require "./config.rb"
require "./driver.rb"
require "./summary-page.rb"

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
		rowVals.push rowContent
	end

	return rowVals.reverse
end

begin
	createDriver
	login
	enterMemorableInfo
	openAccount 1
	
	rowVals = getRowsOnScreen

	`clear`
	rowVals.each do |row|
		puts "Received  #{row[:money_in].ljust(8," ")}  from  '#{row[:name]}'"
	end

	@driver.find_elements(:css=>"a.back-to-accounts-btn").click
	openAccount 1

	rowVals = getRowsOnScreen
	
	`clear`
	rowVals.each do |row|
		puts "Received  #{row[:money_in].ljust(8," ")}  from  '#{row[:name]}'"
	end
	
# rescue Exception => e 
# 	puts "\n\nERROR!!! ERROR!!! ERROR!!!\n\n"
# 	puts e.message
# 	e.backtrace.each do |w|; puts w; end;
ensure
	#@driver.quit if @driver != nil
end
