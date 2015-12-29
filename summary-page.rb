def login
	@driver.get "https://online.lloydsbank.co.uk/personal/logon/login.jsp"
	print "Entering user ID and password... "  
	@driver.find_element(:id => "frmLogin:strCustomerLogin_userID").send_keys @userId
	@driver.find_element(:id => "frmLogin:strCustomerLogin_pwd").send_keys @passwd
	click "frmLogin:btnLogin1"
	puts "done"
end

def enterMemorableInfo
	print "Entering memorable info... "
	for i in 1..3
		selectId = "frmentermemorableinformation1:strEnterMemorableInformation_memInfo#{i}"
		label = @driver.find_element :xpath => "//label[@for='#{selectId}']"
		index = label.text.gsub(/Character/, '').gsub(/:/, '').strip.to_f
		setSelected selectId, "&nbsp;#{@memInfo[index-1]}"
	end
	click "frmentermemorableinformation1:btnContinue"
	puts "done"
end

def openAccount index
	click "ifCommercial:ifCustomerBar:outputLinkNavHome"
	account = @driver.find_element :id => "lnkAccName_des-m-sat-xx-#{index}"
	accountName = account.text
	print "Opening account '#{accountName}'... "
	click "lnkAccName_des-m-sat-xx-#{index}"
	puts "done"
	accountName
end

def downloadMonth month, year
	month = ("%02d" % month).to_s
	year = year.to_s

	print "Downloading #{month}-#{year} for account '#{@accountName}'... "

	@driver.get "https://secure.lloydsbank.co.uk/personal/a/viewproductdetails/ress/m44_exportstatement_fallback.jsp"

	@driver.find_element(:css => '.calendar-date-range-container label').click

	enterDate 'export-date-range-from', "01", month, year
	enterDate 'export-date-range-to', "31", month, year

	setSelected "export-format", "Internet banking text/spreadsheet (.CSV)"
	click "export-statement-form:btnQuickTransferRetail"

	puts "done"
end

def enterDate element, day, month, year
	el = @driver.find_element(:id => element)
	el.send_keys
	el.send_keys(day)
	el.send_keys(month)
	el.send_keys(year)
	raise "Input failed!" if el.attribute("value") != "#{day}/#{month}/#{year}"
end