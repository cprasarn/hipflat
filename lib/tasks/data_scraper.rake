desc "Run data scraper to collect the buildings data from Hipflat website"
task :data_scraper => :environment do
  puts "Data scraper"
  DataScraperWorker.new.perform
  puts "done."
end
