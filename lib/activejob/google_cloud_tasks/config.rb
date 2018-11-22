module Activejob
  module GoogleCloudTasks
    class Config
      DEFAULT_PATH = '/activejobs'

      def self.path
        defined?(@path) ? @path : DEFAULT_PATH
      end

      def self.path=(path)
        @path = path ? path : DEFAULT_PATH
      end
    end
  end
end
