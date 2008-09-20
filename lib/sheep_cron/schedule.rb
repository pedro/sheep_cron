class SheepCron::Schedule
  attr_accessor :job, :interval, :at, :exceptions, :next_execution, :prev_execution

  def initialize(job, options)
    @job = job

    @interval = options[:every]
    @at = options[:at]
    @exceptions = options[:exceptions]

    @next_execution = Chronic.parse(complete(@at, Time.now), :context => :future)
    schedule_next_execution
    @prev_execution = nil
  end

  def schedule_next_execution
    self.prev_execution = next_execution
    self.next_execution = prev_execution + interval
    if interval >= 1.month
      self.next_execution = Chronic.parse(base_reference, :now => self.next_execution, :context => :future)
    end
  end

  def allowed?
    exceptions.all? { |e| !e.call(@next_execution) }
  end

  def base_reference
    return at if interval < 1.month
    complete(at, next_execution)
  end

  def complete(at, date)
    at = at.gsub(/\.|,/, '') if at
    at = complete_time(at, date)
    at = complete_day(at, date) if interval >= 1.week
    at = complete_month(at, date) if interval >= 1.month
    return at
  end

  def complete_time(at, date)
    return at if at =~ /am|pm|\d:\d\d/i
    if at.nil? || at.strip.empty?
      "12:00"
    else
      "#{at} 12:00"
    end
  end

  def complete_day(at, date)
    weekdays = %w( mon tue wed thu fri sat sun )
    return at if at =~ /^\d+(\,|\s)?/
    return at if weekdays.any? { |d| at =~ /#{d}/i }
    if interval < 1.month
      weekday = weekdays(date.wday - 1)
      return "#{weekday} #{at}"
    else
      return "#{date.day} #{at}"
    end
  end

  def complete_month(at, date)
    months = %w( jan feb mar apr may jun jul aug sep oct nov dez )
    month = months[date.month - 1]
    return at if months.any? { |m| at =~ /#{m}/i }
    "#{month} #{at}"
  end
end