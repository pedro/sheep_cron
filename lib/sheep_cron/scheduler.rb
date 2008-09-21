class SheepCron::Scheduler
  class << self
    def jobs
      @@jobs ||= []
    end

    def schedules
      @@schedules ||= []
    end

    def schedule(job, options)
      add(SheepCron::Schedule.new(job, options))
      restart
    end

    def add(new_schedule)
      # insert new_schedule in array, keeping it ordered by next_execution
      pos = 0
      schedules.each_with_index do |s, i|
        break if s.next_execution > new_schedule.next_execution
        pos = i + 1
      end
      schedules.insert(pos, new_schedule)
    end

    def start
      pids << fork do
        loop do
          schedule = schedules.shift
          sleep schedule.waiting_time
          schedule.schedule_next_execution
          add(schedule)
          schedule.job.run
        end
      end
    end

    def stop
      pids.each { |pid| Process.kill('HUP', pid) }
      pids.clear
    end

    def restart
      stop
      start
    end

    def reset
      stop
      schedules.clear
    end

    def pids
      @@pids ||= []
    end
  end
end