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

# Run on production at 04:00 am EST or 3:00 am EDT
every 1.day, at: '09:00 am', roles: [:prod] do
  command "(cd /opt/aspace_helpers/current/reports/aspace2alma && bundle exec ruby get_MARCxml.rb) > get_Marcxml.log 2>&1"
end
