require 'find'
#
# Run this rake task as:
#   rake db:backup DIR=/home/sugarstats RAILS_ENV=production MAX=10
# 
# DIR is the path to create/find a directory called 'backups', defaults to 'db'
# RAILS_ENV is the Rails environment you want to use, defaults to 'production'
# MAX is the total number of backups to keep, defaults to 20
# 
# Like all rake tasks, it’s expecting to be run from the application directory, so the cron task needs to change the directory first.
#   cd /app_dir && rake db:backup
#
namespace :db do
  desc "Backup the database to a file. Options: DIR=base_dir RAILS_ENV=production MAX=20" 
  task :backup => [:environment] do
    # set variables and determine paths and file names
    env_config = ENV["RAILS_ENV"] || 'production'
    db = ActiveRecord::Base.configurations[env_config]
    max_backups = [(ENV["MAX"] || 20).to_i, 1].max
    base_path = ENV["DIR"] || "db"
    backup_base = File.join(base_path, 'backups')
    backup_dir = File.join(backup_base, Time.now.strftime("%Y-%m-%d_%H-%M-%S"))
    backup_file = File.join(backup_dir, "#{db['database']}.sql.gz")
    # e.g. RAILS_BASE/db/backups/2007-09-01_11-30-07/sample_app_production.sql.gz

    # create or find the backup directory (directory name name will be a date-stamp inside 'backups')
    FileUtils.makedirs(backup_dir)
    
    # perform the database dump using the mysqldump command
    # NB: There is a locking bug in older versions of mysqldump. --skip-lock-tables fixes it.
    sh "mysqldump -h #{db['host'] || 'localhost'} -u #{db['username']} --password=#{db['password']} --opt --skip-lock-tables #{db['database']} | gzip -c > #{backup_file}"
    puts "Created backup: #{backup_file}"
    
    # find the directory one level above backup_dir
    dir = Dir.new(backup_base)
    # sort the backup folders by name (which is a date)
    # It uses only [2..-1] to omit '.' and '..'
    all_backups = dir.entries[2..-1].sort.reverse
    # determine the backups to erase
    unwanted_backups = all_backups[max_backups..-1] || []
    unwanted_backups.each {|bu| FileUtils.rm_rf(File.join(backup_base, bu)); puts "Deleted backup: #{bu}" }
    puts "Deleted #{unwanted_backups.length} backups, #{all_backups.length - unwanted_backups.length} backups available" 
  end
end
