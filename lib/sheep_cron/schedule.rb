class Schedule
  attr_accessor :job, :interval, :at, :exceptions, :next_execution

  def initialize(job, options)
    @job = job

    @interval = options[:interval]
    @at = options[:at]
    @exceptions = options[:exceptions]
  end
end