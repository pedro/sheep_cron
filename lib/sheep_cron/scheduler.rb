class SheepCron::Scheduler
  class << self
    def jobs
      @@jobs ||= []
    end

    def schedule(job, options)
      SheepCron::Schedule.new(job, options)
    end
  end
end