require File.dirname(__FILE__) + '/base'

describe SheepCron::Job do
  before do
    @job = SheepCron::Job.new
  end

  it "run saves a proc when called with param" do
    proc = lambda { :test }
    @job.run proc
    @job.proc.should == proc
  end

  it "run executes the proc when called with no params" do
    @job.proc = mock('job proc')
    @job.proc.should_receive(:call)
    @job.run
  end

  it "saves schedules so scheduler can process them later" do
    @job.schedule :every => 10.minutes
    @job.schedule :every => 1.month
    @job.schedules.should == [{ :every => 10.minutes }, { :every => 1.month }]
  end
end