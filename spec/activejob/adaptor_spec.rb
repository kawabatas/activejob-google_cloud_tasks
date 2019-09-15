require_relative '../spec_helper.rb'

RSpec.describe Activejob::GoogleCloudTasks::Adapter do
  let(:client) { spy('Google::Cloud::Tasks') }
  let(:queue) { 'my-queue' }
  let(:project) { 'my-project' }
  let(:location) { 'my-location' }
  subject {
    Activejob::GoogleCloudTasks::Adapter.new(
      project: project, location: location, cloud_tasks_client: client)
  }

  before do
    eval <<-JOB
      class GreetJob < ActiveJob::Base
        queue_as "#{queue}"
        def perform(name, suffix='!', prefix: 'hello')
          "\#{prefix} \#{name}\#{suffix}"
        end
      end
    JOB
  end


  describe '#enqueue' do
    let(:job) { GreetJob.new('foo', ':)', prefix: 'howdy') }

    it 'creates cloud tasks job' do
      subject.enqueue(job)

      expect(client).to have_received(:create_task).with(
        "projects/#{project}/locations/#{location}/queues/#{queue}",
        {
          app_engine_http_request: {
              http_method: :GET,
              relative_uri: \
                Activejob::GoogleCloudTasks::Config.path +
                '/perform?job=GreetJob&params%5B%5D=foo&params%5B%5D=%3A%29&params%5B%5D%5Bprefix%5D=howdy'
            }
        }
      )
    end

    it 'creates cloud tasks job with schedule' do
      scheduled_at = 1.hour.since
      subject.enqueue(job, scheduled_at: scheduled_at)

      expect(client).to have_received(:create_task).with(
        "projects/#{project}/locations/#{location}/queues/#{queue}",
        {
          app_engine_http_request: {
              http_method: :GET,
              relative_uri: \
                Activejob::GoogleCloudTasks::Config.path +
                '/perform?job=GreetJob&params%5B%5D=foo&params%5B%5D=%3A%29&params%5B%5D%5Bprefix%5D=howdy'
          },
          schedule_time: Google::Protobuf::Timestamp.new(seconds: scheduled_at.to_i)
        }
      )
    end
  end
end
