class SheepCron::Scheduler
  class << self
    def jobs
      @@jobs ||= []
    end

    def schedule(job, options)
      Schedule.new(job, options)
    end
  end
end