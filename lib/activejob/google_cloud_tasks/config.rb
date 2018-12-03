module Activejob
  module GoogleCloudTasks
    class Config
      DEFAULT_PATH = '/activejobs'

      def self.path
        @path.presence || DEFAULT_PATH
      end

      def self.path=(path)
        raise "path can't be blank" unless path.present?
        @path = path
      end
    end
  end
end
