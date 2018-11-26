# Activejob::GoogleCloudTasks

[![Build Status](https://travis-ci.org/kawabatas/activejob-google_cloud_tasks.svg?branch=master)](https://travis-ci.org/kawabatas/activejob-google_cloud_tasks)
[![Gem Version](https://badge.fury.io/rb/activejob-google_cloud_tasks.svg)](https://badge.fury.io/rb/activejob-google_cloud_tasks)

Google Cloud Tasks adapter for ActiveJob

## Prerequisites
- [Creating App Engine Queues](https://cloud.google.com/tasks/docs/creating-appengine-queues)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activejob-google_cloud_tasks', '>= 0.1.2'
```

## Usage

First, change the ActiveJob backend.

``` ruby
Rails.application.config.active_job.queue_adapter = Activejob::GoogleCloudTasks::Adapter.new(
  project: 'MY_GOOGLE_CLOUD_TASKS_PROJECT',
  location: 'MY_GOOGLE_CLOUD_TASKS_LOCATION'
)
```

Second, mount the rack application.

``` ruby
Rails.application.routes.draw do
  mount Activejob::GoogleCloudTasks::Rack, at: Activejob::GoogleCloudTasks::Config.path
end
```

Write the Job class and code to use it.
Note: The argument is one and it must be hash.

``` ruby
class SampleJob < ApplicationJob
  queue_as :default
  def perform(args)
    puts "hello, #{args[:name]}!"
  end
end
```

``` ruby
class SampleController < ApplicationController
  def job
    SampleJob.perform_later({name: 'ken'})
  end
end
```

### Adapter
``` ruby
Rails.application.config.active_job.queue_adapter = Activejob::GoogleCloudTasks::Adapter.new(
  project: 'MY_GOOGLE_CLOUD_TASKS_PROJECT',
  location: 'MY_GOOGLE_CLOUD_TASKS_LOCATION',

  cloud_tasks_client: Google::Cloud::Tasks.new(
    version: :v2beta3,
    credentials: 'path/to/keyfile.json'
  )
)
```

#### Argument Reference
- `project` - (Required) The ID of the Google Cloud project in which the Cloud Tasks belongs.

- `location` - (Required) The Location of the Cloud Tasks.

- `cloud_tasks_client` - (Optional) The instance of `Google::Cloud::Tasks`. Please see [`Google::Cloud::Tasks.new`](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-tasks/latest/Google/Cloud/Tasks.html#new-class_method) for details. Default: `Google::Cloud::Tasks.new(version: :v2beta3)`

### Config
```
Activejob::GoogleCloudTasks::Config.path = '/foo'
```

- `path` - (Optional) The path which the Cloud Tasks service forwards the task request to the worker. Default: `/activejobs`

## Development

``` sh
$ bundle exec rake spec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kawabatas/activejob-google_cloud_tasks.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
