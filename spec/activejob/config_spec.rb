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

  it "raises if blank path is to be set" do
    expect { subject.path = nil }.to raise_error(RuntimeError)
    expect { subject.path = '' }.to raise_error(RuntimeError)
  end
end
