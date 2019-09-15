require 'rack'

# Rack handler endpoint to perform the task.
# Expects a `PATH_INFO` of /perform with a `QUERY_STRING` that
# contains a `job` and `params` key. Where `job` is the name
# of the handler class and `params` is a serialized string of
# arguments for the handler.
module Activejob
  module GoogleCloudTasks
    class Rack
      class << self
        def call(env)
          if env['PATH_INFO'].match(/^\/perform/)
            params = parsed_params(env['QUERY_STRING'])
            unless params.has_key?(:job)
              raise StandardError, "Job is not specified."
            end

            klass(params[:job]).perform_now(*params[:params])
            [200, {}, ['ok']]
          else
            [404, {}, ['not found']]
          end
        end

        private

        def klass(job)
          Kernel.const_get(job.camelize)
        end

        def parsed_params(query_string)
          params = ::Rack::Utils.parse_nested_query(query_string)
          HashWithIndifferentAccess.new params
        end

      end
    end
  end
end
