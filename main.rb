require 'selenium-webdriver'
require 'pp'
require 'CSV'

require "./config.rb"
require "./driver.rb"
require "./files.rb"
require "./summary-page.rb"

begin
	m = (getMostRecentDate..Date.today).map{|d| [d.year, d.month]}.uniq
	m.shift
	m = m.reverse
	m.shift

	if m.length == 0
		puts "No complete months to download"
		raise "nothing"
	end

	cleanupFiles :concat_included => true

	createDriver

	login
	enterMemorableInfo

	[1,3,4].each do |i|
		@accountName = openAccount i

		cleanupFiles :concat_included => false

		m.reverse.each do |my|
			downloadMonth my[1], my[0]
		end

		concatenateFiles @accountName
		cleanupFiles :concat_included => false
	end
rescue Exception => e 
	exit if e.message=="nothing"
	puts "\n\nERROR!!! ERROR!!! ERROR!!!\n\n"
	puts e.message
	e.backtrace.each do |w|; puts w; end;
ensure
	@driver.quit if @driver != nil
end