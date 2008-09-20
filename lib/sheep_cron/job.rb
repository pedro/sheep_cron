class SheepCron::Job
  attr_accessor :name, :proc, :scheduler

  def initialize(scheduler)
    @scheduler = scheduler
  end

  # accessor: if called with param will store 
  # proc, otherwise it will run the one stored
  def run(proc=nil)
    if proc
      self.proc = proc
    else
      self.proc.call
    end
  end

  def to_s
    name
  end

  def schedule(options)
    scheduler.schedule(self, options)
  end
end