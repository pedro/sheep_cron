require File.dirname(__FILE__) + '/base'

describe SheepCron::Scheduler do
  before(:each) do
    @file = '/tmp/sheep_cron_spec'
    File.delete(@file) rescue nil
    @job = SheepCron::Job.new(SheepCron::Scheduler)
    @job.run lambda { File.open(@file, 'a') { |f| f.write Time.now.to_s + "\n" } }
  end

  it "works :)" do
    SheepCron::Scheduler.schedule(@job, :every => 1.second)
    sleep(2.1)
    SheepCron::Scheduler.stop
    out = File.readlines(@file)
    out.size.should == 2
    Time.parse(out[0]).sec.should < Time.parse(out[1]).sec
  end

  it "is not delayed by the job execution" do
    @job.run lambda { File.open(@file, 'a') { |f| f.write Time.now.to_s + "\n" }; sleep(0.5) }
    SheepCron::Scheduler.schedule(@job, :every => 1.second)
    sleep(2.1)
    SheepCron::Scheduler.stop
    File.readlines(@file).size.should == 2
  end

  it "runs multiple schedules in parallel" do
    SheepCron::Scheduler.schedule(@job, :every => 1.second, :except => lambda { |t| t.sec % 2 == 0 })
    SheepCron::Scheduler.schedule(@job, :every => 1.second, :except => lambda { |t| t.sec % 2 == 1 })
    sleep(2.1)
    SheepCron::Scheduler.stop
    File.readlines(@file).size.should == 2
  end

  it "runs multiple jobs in parallel" do
    @job.run lambda { File.open(@file, 'a') { |f| f.write "1\n" } }
    @job2 = SheepCron::Job.new(SheepCron::Scheduler)
    @job2.run lambda { File.open(@file, 'a') { |f| f.write "2\n" } }
    SheepCron::Scheduler.schedule(@job,  :every => 1.second, :except => lambda { |t| t.sec % 2 == 0 })
    SheepCron::Scheduler.schedule(@job2, :every => 1.second, :except => lambda { |t| t.sec % 2 == 1 })
    sleep(3.1)
    SheepCron::Scheduler.stop
    out = File.readlines(@file)
    out.size.should == 3
    out[0].should == out[2]
    out[0].should_not == out[1]
  end
end