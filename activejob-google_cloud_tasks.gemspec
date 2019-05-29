
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "activejob/google_cloud_tasks/version"

Gem::Specification.new do |spec|
  spec.name          = "activejob-google_cloud_tasks"
  spec.version       = Activejob::GoogleCloudTasks::VERSION
  spec.authors       = ["Kawabata Shintaro"]
  spec.email         = [""]

  spec.summary       = "Google Cloud Tasks adapter for ActiveJob"
  spec.homepage      = "https://github.com/kawabatas/activejob-google_cloud_tasks"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'rack', ">= 2.0.6"
  spec.add_runtime_dependency 'activejob'
  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'google-cloud-tasks', '>= 0.2.6', '< 1.1.0'

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rack-test"
end
