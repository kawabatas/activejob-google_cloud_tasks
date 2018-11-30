require_relative '../spec_helper.rb'
require 'rack/test'

RSpec.describe Activejob::GoogleCloudTasks::Rack do
  include Rack::Test::Methods

  let(:app) { Activejob::GoogleCloudTasks::Rack }

  it 'can perform Job' do
    job_klass = spy('GreetJob')
    expect(app).to receive(:klass) { job_klass }

    params = { job: 'GreetJob', foo: 'bar' }
    get '/perform', params
    expect(last_response.status).to eq(200)
    expect(job_klass).to have_received(:perform_now).with(params)
  end

  it 'raises NameError for unknown job' do
    expect { get '/perform', job: 'UnknownJob' }.to raise_error(NameError)
  end
end
