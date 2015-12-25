require 'pp'
require 'CSV'

current = CSV.read("concat-current - pristine.csv")
savings = CSV.read("concat-savings - pristine.csv")

#Remove headings
current.delete_at 0
savings.delete_at 0

#Calculate net totals
netTotals = []

current.each do |row|
		if row[5] != nil
			row[6] = (row[5].to_f * -1).to_s
		end
		netTotals.push [row[0], row[6]]
end

savings.each do |row|
		if row[5] != nil
			row[6] = (row[5].to_f * -1).to_s
		end
		netTotals.push [row[0], row[6]]
end

# Operate on net totals - get total for each date

allDates = []

netTotals.each do |row|
	allDates.push row[0]
end

allDates.uniq!

newRows = []
allDates.each do |date|
	matches = []
	netTotals.each do |row|
		if row[0] == date
			matches.push row
		end
	end	
	newEntry = [date, 0]
	matches.each do |match|
		newEntry[1] += match[1].to_f
	end
	newRows.push newEntry
end

#Order by date
newRows.sort! do |a, b|
	 Date.parse(a[0]) <=> Date.parse(b[0])
end

# Add total column
newRows[0][2] = newRows[0][1]
newRows.each_index do |index|
	if index != 0
		newRows[index][2] = newRows[index-1][2] + newRows[index][1]
	end
end

# Add headings
newRows.insert 0, ["date", "change", "balance"]

#Write to file
begin
	File.delete "final output.csv"
rescue
ensure
	CSV.open("final output.csv", "w") do |csv|
		newRows.each do |row|
	  		csv << row
	  	end
	end
end