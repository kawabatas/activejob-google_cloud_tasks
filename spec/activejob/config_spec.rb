require_relative '../spec_helper.rb'

RSpec.describe Activejob::GoogleCloudTasks::Config do
  subject { Activejob::GoogleCloudTasks::Config }

  it "have default path value" do
    expect(subject.path).to eq '/activejobs'
  end

  it "changes arbitrary path" do
    subject.path = '/jobs'
    expect(subject.path).to eq '/jobs'
  end
end
