class SheepCron::Schedule
  attr_accessor :job, :interval, :at, :exception, :next_execution, :prev_execution

  def initialize(job, options)
    @job = job

    @interval = options[:every]
    @at = options[:at]
    @exception = options[:except]

    if @interval < 1.day
      # dealing with a bug in chronic that will add a day even when
      # the time is still available today (ie it's a monday 1:00pm, we 
      # ask chronic to parse "1:01pm" and it returns tue 1:01pm)
      @next_execution = Time.now
    else
      @next_execution = Chronic.parse(complete(@at, Time.now), :context => :future)
    end
    schedule_next_execution
    @prev_execution = nil
  end

  def schedule_next_execution
    self.prev_execution = next_execution
    calculate_next_execution(prev_execution)
    calculate_next_execution(next_execution) while !allowed?
  end

  def calculate_next_execution(starting_at)
    self.next_execution = starting_at + interval
    if interval >= 1.month
      self.next_execution = Chronic.parse(base_reference, :now => self.next_execution, :context => :future)
    end
  end

  def allowed?
    return true if exception.nil?
    !exception.call(next_execution)
  end

  def base_reference
    return at if interval < 1.month
    complete(at, next_execution)
  end

  def complete(at, date)
    at = at.gsub(/\.|,/, '') if at
    at = complete_time(at, date)
    at = complete_day(at, date)
    at = complete_month(at, date) if interval >= 1.month
    return at
  end

  def complete_time(at, date)
    return at if at =~ /am|pm|\d:\d\d/i
    now = date.strftime("%H:%M:%S")
    if at.nil? || at.strip.empty?
      now
    else
      "#{at} #{now}"
    end
  end

  def complete_day(at, date)
    return at if interval < 1.month
    return at if at =~ /^\d+$/ || at =~ /^\d+\s/
    return at if %w( mon tue wed thu fri sat sun ).any? { |d| at =~ /#{d}/i }
    if interval >= 1.month
      return "#{date.day} #{at}"
    end
  end

  def complete_month(at, date)
    months = %w( jan feb mar apr may jun jul aug sep oct nov dez )
    month = months[date.month - 1]
    return at if months.any? { |m| at =~ /#{m}/i }
    "#{month} #{at}"
  end

  def waiting_time
    next_execution - Time.now
  end
end