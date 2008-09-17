require 'rubygems'
require 'activesupport'

module SheepCron; end
require File.dirname(__FILE__) + '/sheep_cron/job'
require File.dirname(__FILE__) + '/sheep_cron/scheduler'
require File.dirname(__FILE__) + '/sheep_cron/schedule'

# easy accessor to add job
def SheepCron
  job = SheepCron::Job.new(SheepCron::Scheduler)
  yield(job)
  SheepCron::Scheduler.jobs << job
end
