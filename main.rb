require 'selenium-webdriver'
require 'pp'

require "./config.rb"
require "./driver.rb"
require "./files.rb"
require "./summary-page.rb"

begin
	cleanupFiles :concat_included => true
	@driver.get "https://online.lloydsbank.co.uk/personal/logon/login.jsp"
	
	login
	enterMemorableInfo

	[1,3,4].each do |i|
		@accountName = openAccount i

		cleanupFiles :concat_included => false

		downloadMonth 9 , 2015
		downloadMonth 10 , 2015
		downloadMonth 11 , 2015

		concatenateFiles @accountName
		cleanupFiles :concat_included => false
	end
rescue Exception => e  
	puts "\n\nERROR!!! ERROR!!! ERROR!!!\n\n"
	puts e.message
	e.backtrace.each do |w|; puts w; end;
ensure
	@driver.quit if @driver != nil
end