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

# Run on production at 03:30 am EST or 2:30 am EDT every morning except
# Monday (Alma jobs are backed up) or Saturday (ASpace maintenance window)
every '30 8 * * 2-5,7', roles: [:prod] do
  command "cd /opt/aspace_helpers/current/reports/aspace2alma && bundle exec ruby get_MARCxml.rb"
end

# Run on production at 03:30 am EST or 2:30 am EDT on days we are skipping aspace2alma:
# Monday (Alma jobs are backed up) or Saturday (ASpace maintenance window)
every '30 8 * * 1,6', roles: [:prod] do
  command "cd /opt/aspace_helpers/current/reports/aspace2alma && bundle exec ruby delete_from_sftp.rb"
end
