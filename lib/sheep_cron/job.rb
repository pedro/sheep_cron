class SheepCron::Job
  attr_accessor :name, :proc, :schedules

  def initialize(attrs={})
    @schedules = []
    attrs.each { |a, v| send("#{a}=", v) }
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
    schedules << options
  end
end