# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# Run on production at 10:30am UTC (6:30 EDT / 5:30 EST) every morning except
# Monday (Alma jobs are backed up) or Saturday (ASpace maintenance window)
every '30 10 * * 2-5,7', roles: [:cron] do
  command "cd /opt/aspace_helpers/current/reports/aspace2alma && bundle exec ruby get_MARCxml.rb"
end

# Run on production at 10:30am UTC (6:30 EDT / 5:30 EST) on days we are skipping aspace2alma:
# Monday (Alma jobs are backed up) or Saturday (ASpace maintenance window)
every '30 10 * * 1,6', roles: [:cron] do
  command "cd /opt/aspace_helpers/current/reports/aspace2alma && bundle exec ruby delete_from_sftp.rb"
end
