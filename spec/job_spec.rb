require File.dirname(__FILE__) + '/base'

describe SheepCron::Job do
  before do
    @scheduler = mock('job scheduler')
    @job = SheepCron::Job.new(@scheduler)
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

  it "delegates the schedule to scheduler" do
    @scheduler.should_receive(:schedule).with(@job, { :every => 10.minutes })
    @job.schedule :every => 10.minutes
  end
end