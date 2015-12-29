def cleanupFiles opts = {}
	Dir.glob("#{@downloadLocation}/*.csv").each do |f|
		next if f =~ /.*concat.*/ && !opts[:concat_included]
		File.delete(f)
	end
end

def concatenateFiles accountName
	fileName = "#{accountName}-concat.csv"
	print "Writing '#{fileName}'... "
	File.open("#{@downloadLocation}/#{fileName}", "w") do |csv|
		headingsAdded = false
		Dir["#{@downloadLocation}/*_*.csv"].each do |fileName|
			contents = File.read fileName
			start = headingsAdded ? 1 : 0
			contents = contents.lines.to_a[start..-1].join
  			csv << contents
  			headingsAdded = true
		end
	end
	puts "done"
end

def load_csv fileName
	file = CSV.read(fileName)
	
	#Remove headings
	file.delete_at 0

	return file
end

def getMostRecentDate
	previous = load_csv("final output.csv")

	oldest = Date.strptime("01/01/1980", "%d/%m/%Y")
	previous.each do |row|
		date = Date.strptime(row[0], "%d/%m/%Y")
		oldest = date if date > oldest
	end
	puts "Already downloaded up to #{oldest}"
	return oldest
end
