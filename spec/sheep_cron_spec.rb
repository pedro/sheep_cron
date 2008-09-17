require File.dirname(__FILE__) + '/base'

describe SheepCron do
  it "is just an accessor to easily create jobs" do
    SheepCron do |j|
      j.name = 'test'
      j.schedule :every => 10.minutes
      j.run lambda { 'test' }
    end
    SheepCron::Scheduler.jobs.size.should == 1
    SheepCron::Scheduler.jobs.first.name.should == 'test'
  end
end