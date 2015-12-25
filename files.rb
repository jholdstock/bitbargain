def cleanupFiles opts = {}
	Dir.glob("#{@downloadLocation}/*.csv").each do |f|
		next if f =~ /.*concat.*/ && !opts[:concat_included]
		File.delete(f)
	end
end

def concatenateFiles accountName
	fileName = "#{accountName}-concat.csv"
	print "Writing #{fileName}... "
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
