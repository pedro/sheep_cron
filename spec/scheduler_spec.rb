require File.dirname(__FILE__) + '/base'

describe SheepCron::Scheduler do
  before do
    @file = '/tmp/sheep_cron_spec'
    File.delete(@file)
    @job = SheepCron::Job.new(SheepCron::Scheduler)
    @job.name = 'test'
    @job.run lambda { File.open(@file, 'a') { |f| f.write Time.now.to_s + "\n" } }
  end

  it "works :)" do
    SheepCron::Scheduler.schedule(@job, :every => 1.seconds)
    sleep(3.2)
    SheepCron::Scheduler.stop
    out = File.readlines(@file)
    out.size.should == 3
    Time.parse(out[0]).sec.should < Time.parse(out[1]).sec
    Time.parse(out[1]).sec.should < Time.parse(out[2]).sec
  end
end