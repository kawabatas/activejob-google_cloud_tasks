require 'rack/test'
require 'google/gax'
require 'google/cloud/tasks'
require 'google/cloud/tasks/v2beta3/cloud_tasks_client'
require 'google/cloud/tasks/v2beta3/cloudtasks_services_pb'
require 'active_job'

PROJECT   = 'my-project'
LOCATION  = 'my-location'
QUEUE     = 'my-queue'
BASE_PATH = '/foo'

class FooJob < ActiveJob::Base
  queue_as QUEUE
  def perform(args)
    "hello, #{args[:name]}!"
  end
end

# Mock for the GRPC::ClientStub class.
# @see https://github.com/googleapis/google-cloud-ruby/blob/master/google-cloud-tasks/test/google/cloud/tasks/v2beta3/cloud_tasks_client_test.rb
class MockGrpcClientStub_v2beta3
  def initialize(expected_symbol, mock_method)
    @expected_symbol = expected_symbol
    @mock_method = mock_method
  end
  def method(symbol)
    return @mock_method if symbol == @expected_symbol
    proc do
      raise "The method #{symbol} was unexpectedly called during the " \
        "test for #{@expected_symbol}."
    end
  end
end

class MockCloudTasksCredentials_v2beta3 < Google::Cloud::Tasks::V2beta3::Credentials
  def initialize(method_name)
    @method_name = method_name
  end
  def updater_proc
    proc do
      raise "The method `#{@method_name}` was trying to make a grpc request. This should not " \
          "happen since the grpc layer is being mocked."
    end
  end
end

RSpec.describe Activejob::GoogleCloudTasks do
  include Rack::Test::Methods

  let(:app) {
    Rack::Builder.new do
      Activejob::GoogleCloudTasks::Config.path = BASE_PATH
      ActiveJob::Base.queue_adapter = Activejob::GoogleCloudTasks::Adapter.new(project: PROJECT, location: LOCATION)
      map BASE_PATH do
        run Activejob::GoogleCloudTasks::Rack
      end
    end.to_app
  }
  let(:formatted_parent) { Google::Cloud::Tasks::V2beta3::CloudTasksClient.queue_path(PROJECT, LOCATION, QUEUE) }
  let(:expected_response) {
    name = "name3373707"
    dispatch_count = 1217252086
    response_count = 424727441
    expected_response = {
      name: name,
      dispatch_count: dispatch_count,
      response_count: response_count
    }
    Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta3::Task)
  }
  let(:mock_credentials) { MockCloudTasksCredentials_v2beta3.new('create_task') }

  it 'can enqueue Defined Unscheduled Job' do
    mock_method = proc do |request|
      expect(request).to be_an_instance_of(Google::Cloud::Tasks::V2beta3::CreateTaskRequest)

      relative_uri = request.task.app_engine_http_request.relative_uri.dup
      relative_uri.slice!(BASE_PATH)
      expect(relative_uri).to match(/^\/perform/)

      expect(request.task.schedule_time).to be_nil
      OpenStruct.new(execute: expected_response)
    end

    mock_stub = MockGrpcClientStub_v2beta3.new(:create_task, mock_method)
    allow(Google::Cloud::Tasks::V2beta3::CloudTasks::Stub).to receive(:new).and_return(mock_stub)
    allow(Google::Cloud::Tasks::V2beta3::Credentials).to receive(:default).and_return(mock_credentials)
    app
    FooJob.perform_later({name: 'ken'})
  end

  it 'can enqueue Defined Schedule Job' do
    mock_method = proc do |request|
      expect(request).to be_an_instance_of(Google::Cloud::Tasks::V2beta3::CreateTaskRequest)

      relative_uri = request.task.app_engine_http_request.relative_uri.dup
      relative_uri.slice!(BASE_PATH)
      expect(relative_uri).to match(/^\/perform/)

      expect(request.task.schedule_time).to_not be_nil
      OpenStruct.new(execute: expected_response)
    end

    mock_stub = MockGrpcClientStub_v2beta3.new(:create_task, mock_method)
    allow(Google::Cloud::Tasks::V2beta3::CloudTasks::Stub).to receive(:new).and_return(mock_stub)
    allow(Google::Cloud::Tasks::V2beta3::Credentials).to receive(:default).and_return(mock_credentials)
    app
    FooJob.set(wait: 1.minutes).perform_later({name: 'ken'})
  end

  it 'can execute Defined Job' do
    get "#{BASE_PATH}/perform?job=FooJob"
    expect(last_response.status).to eq(200)
  end

  it 'raises an error when executing Undefined Job' do
    expect { get "#{BASE_PATH}/perform?job=BarJob" }.to raise_error(NameError)
  end

  it 'raises an error when executing without Job parameter' do
    expect { get "#{BASE_PATH}/perform" }.to raise_error(StandardError)
  end

  it 'handles requests other than execute' do
    get "#{BASE_PATH}/other"
    expect(last_response.status).to eq(404)
  end
end
