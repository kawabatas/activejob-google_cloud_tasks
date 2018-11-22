require 'rack'

module Activejob
  module GoogleCloudTasks
    class Rack
      class << self
        def call(env)
          if env['PATH_INFO'].match(/^\/perform/)
            params = Hash[URI::decode_www_form(env['QUERY_STRING'])].symbolize_keys
            raise StandardError, "Job is not specified." unless params.has_key?(:job)

            klass(params[:job]).perform_now(params)
            [200, {}, ['ok']]
          else
            [404, {}, ['not found']]
          end
        end

        private

        def klass(job)
          Kernel.const_get(job.camelize)
        end
      end
    end
  end
end
