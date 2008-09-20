require File.dirname(__FILE__) + '/base'

describe SheepCron::Schedule do
  before do
    Time.stub!(:now).and_return(Time.mktime(2008, 1, 7, 12, 00, 00)) # monday
    @job = mock('job')
  end

  it "initializes setting the next execution" do
    @schedule = SheepCron::Schedule.new(@job, :every => 10.minutes)
    @schedule.next_execution.should == Time.mktime(2008, 1, 7, 12, 10, 00)
  end

  it "initializes with no prev execution date" do
    @schedule = SheepCron::Schedule.new(@job, :every => 10.minutes)
    @schedule.prev_execution.should be_nil
  end

  context "daily schedules" do
    it "uses the :at option to set the next execution on a specific time" do
      @schedule = SheepCron::Schedule.new(@job, :every => 1.day, :at => '1pm')
      @schedule.next_execution.should == Time.mktime(2008, 1, 8, 13, 00, 00)
    end

    it "sets the next execution to the current time in case :at is not specified" do
      Time.stub!(:now).and_return(Time.mktime(2008, 1, 7, 15, 33, 00))
      @schedule = SheepCron::Schedule.new(@job, :every => 1.day)
      @schedule.next_execution.should == Time.mktime(2008, 1, 8, 15, 33, 00)
    end
  end

  context "weekly schedules" do
    it "uses the :at option to set the next execution on a specific day of the week" do
      @schedule = SheepCron::Schedule.new(@job, :every => 3.weeks, :at => 'tuesday')
      @schedule.next_execution.should == Time.mktime(2008, 1, 29, 12, 00, 00)
    end

    it "sets the next execution to the current week day in case :at is not specified" do
      @schedule = SheepCron::Schedule.new(@job, :every => 3.weeks)
      @schedule.next_execution.should == Time.mktime(2008, 1, 28, 12, 00, 00)
    end
  end

  context "monthly schedules" do
    it "uses the :at option to set the next execution to a specific day" do
      @schedule = SheepCron::Schedule.new(@job, :every => 1.month, :at => '1')
      @schedule.next_execution.should == Time.mktime(2008, 2, 1, 12, 00, 00)
    end

    it "sets the next execution to the current day in case :at is not specified" do
      @schedule = SheepCron::Schedule.new(@job, :every => 1.month)
      @schedule.next_execution.should == Time.mktime(2008, 2, 7, 12, 00, 00)
    end
  end

  context "simulation" do
    it "rescheduling with time" do
      @schedule = SheepCron::Schedule.new(@job, :every => 50.minutes)
      @schedule.next_execution.should == Time.mktime(2008, 1, 7, 12, 50, 00)
      @schedule.schedule_next_execution
      @schedule.next_execution.should == Time.mktime(2008, 1, 7, 13, 40, 00)
      @schedule.schedule_next_execution
      @schedule.next_execution.should == Time.mktime(2008, 1, 7, 14, 30, 00)
    end

    it "rescheduling with days" do
      @schedule = SheepCron::Schedule.new(@job, :every => 3.days, :at => '6pm')
      @schedule.next_execution.should == Time.mktime(2008, 1, 10, 18, 00, 00)
      @schedule.schedule_next_execution
      @schedule.next_execution.should == Time.mktime(2008, 1, 13, 18, 00, 00)
      @schedule.schedule_next_execution
      @schedule.next_execution.should == Time.mktime(2008, 1, 16, 18, 00, 00)
    end

    it "rescheduling with months" do
      @schedule = SheepCron::Schedule.new(@job, :every => 2.months, :at => '15, 6pm')
      @schedule.next_execution.should == Time.mktime(2008, 3, 15, 18, 00, 00)
      @schedule.schedule_next_execution
      @schedule.next_execution.should == Time.mktime(2008, 5, 15, 18, 00, 00)
      @schedule.schedule_next_execution
      @schedule.next_execution.should == Time.mktime(2008, 7, 15, 18, 00, 00)
    end
  end
end