# prefs = {
#   :download => {
#      :prompt_for_download => "false", 
#     :default_directory => @downloadLocation
#   }
# }

# @driver = Selenium::WebDriver.for :chrome, :prefs => prefs

@driver = Selenium::WebDriver.for :chrome
def setSelected selectId, value
	select = Selenium::WebDriver::Support::Select.new @driver.find_element(:id => selectId)
	select.select_by :value, value
end

def click elementId
	@driver.find_element(:id => elementId).click
	sleep 1
end
