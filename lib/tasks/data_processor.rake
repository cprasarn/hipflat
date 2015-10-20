desc "Run data processor to process the buildings data"
task :data_processor => :environment do
  puts "Data processor"
  DataProcessorWorker.new.perform
  puts "done."
end
