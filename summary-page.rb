def login
	@driver.get "https://online.lloydsbank.co.uk/personal/logon/login.jsp"
	print "Entering user ID and password... "  
	@driver.find_element(:id => "frmLogin:strCustomerLogin_userID").send_keys @userId
	@driver.find_element(:id => "frmLogin:strCustomerLogin_pwd").send_keys @passwd
	click "frmLogin:btnLogin2"
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
	account = @driver.find_element :id => "lnkAccName_des-m-sat-xx-#{index}"
	accountName = account.text
	print "Opening account '#{accountName}'... "
	click "lnkAccName_des-m-sat-xx-#{index}"
	puts "done"
	accountName
end
