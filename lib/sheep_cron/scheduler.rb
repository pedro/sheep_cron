class SheepCron::Scheduler
  class << self
    def jobs
      @@jobs ||= []
    end

    def schedule(job, options)
      @@schedules ||= []
      @@schedules << new_schedule = SheepCron::Schedule.new(job, options)
      ensure_covered(new_schedule)
    end

    def ensure_covered(schedule)
      return start(schedule) if !running?
      return restart(schedule) if next_schedule.next_execution > schedule.next_execution
    end

    def pid
      @@pid ||= nil
    end

    def running?
      !pid.nil?
    end

    def start(schedule)
      @@pid = fork do
        loop do
          sleep schedule.waiting_time
          schedule.schedule_next_execution
          schedule.job.run
        end
      end
    end

    def stop
      Process.kill('HUP', pid) if pid
    end

    def next_schedule
      @@next_schedule ||= nil
    end
  end
end