require 'activejob/google_cloud_tasks/config'
require 'google/cloud/tasks/v2beta3'

module Activejob
  module GoogleCloudTasks
    class Adapter
      def initialize(project:, location:)
        @project = project
        @location = location
        @cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta3)
      end

      def enqueue(job, attributes = {})
        formatted_parent = Google::Cloud::Tasks::V2beta3::CloudTasksClient.queue_path(@project, @location, job.queue_name)
        relative_uri = "#{Activejob::GoogleCloudTasks::Config.path}/perform?job=#{job.class.to_s}&#{job.arguments.to_param}"

        task = {
          app_engine_http_request: {
            http_method: :GET,
            relative_uri: relative_uri
          }
        }
        task[:schedule_time] = Google::Protobuf::Timestamp.new(seconds: attributes[:scheduled_at].to_i) if attributes.has_key?(:scheduled_at)
        @cloud_tasks_client.create_task(formatted_parent, task)
      end

      def enqueue_at(job, scheduled_at)
        enqueue job, scheduled_at: scheduled_at
      end
    end
  end
end
