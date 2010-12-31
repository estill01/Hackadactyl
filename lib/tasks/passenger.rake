namespace :passenger do
  desc "Restart Application"
  task :restart do
    $stderr.puts "Restarting Passenger on #{Time.now.strftime("%A, %b %e at %I:%M:%S %p")}"
    system 'touch tmp/restart.txt'
  end
end

namespace :passenger do
  desc "Restart Application"
  task :restart do
    $stderr.puts "Restarting Passenger on #{Time.now.strftime("%A, %b %e at %I:%M:%S %p")}"
    system 'touch tmp/restart.txt'
  end
end


