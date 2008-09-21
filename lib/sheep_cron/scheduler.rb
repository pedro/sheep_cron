class SheepCron::Scheduler
  class << self
    def jobs
      @@jobs ||= []
    end

    def schedule(job, options)
      @@schedules ||= []
      @@schedules << new_schedule = SheepCron::Schedule.new(job, options)
      start(new_schedule)
    end

    def start(schedule)
      pids << fork do
        loop do
          sleep schedule.waiting_time
          schedule.schedule_next_execution
          schedule.job.run
        end
      end
    end

    def stop
      pids.each { |pid| Process.kill('HUP', pid) }
      pids.clear
    end

    def pids
      @@pids ||= []
    end
  end
end