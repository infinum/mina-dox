# Mina::Dox

This is a mina plugin for [dox](https://github.com/infinum/dox).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mina-dox', require: false
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mina-dox

## Usage

Add to your `deploy.rb`

```ruby
require 'mina-dox'
```

## Variables

```
set :dox_version, 'v1'
set :dox_path, "api/#{fetch(:dox_version)}/docs"
```

## Tasks

```ruby
:dox:generate # Assumes you have a rake task called 'dox:html'
:dox:publish  # Publishes the generated docs
```

## Dox generating task:

Example:
```ruby
namespace :dox do
  task :md, [:version, :docs_path, :host] do |_, args|
    require 'rspec/core/rake_task'

    version = args[:version] || :v1
    docs_path = args[:docs_path] || "api/${version}/docs"

    RSpec::Core::RakeTask.new(:api_spec) do |t|
      t.pattern = "spec/requests/#{version}/"
      t.rspec_opts =
        "-f Dox::Formatter --order defined -t dox -o public/#{docs_path}/apispec.md.erb"
    end

    Rake::Task['api_spec'].invoke
  end

  task :html, [:version, :docs_path, :host] => :erb do |_, args|
    version = args[:version] || :v1
    docs_path = args[:docs_path] || "api/${version}/docs"
    `node_modules/.bin/aglio -i public/#{docs_path}/apispec.md -o public/#{docs_path}/index.html --theme-full-width --theme-variables flatly`
  end

  task :open, [:version, :docs_path, :host] => :html do |_, args|
    version = args[:version] || :v1
    docs_path = args[:docs_path] || "api/${version}/docs"

    `open public/#{docs_path}/index.html`
  end

  task :erb, [:version, :docs_path, :host] => [:environment, :md] do |_, args|
    require 'erb'

    host = args[:host] || 'http://localhost:3000'
    version = args[:version] || :v1
    docs_path = args[:docs_path] || "api/${version}/docs"

    File.open("public/#{docs_path}/apispec.md", 'w') do |f|
      f.write(ERB.new(File.read("public/#{docs_path}/apispec.md.erb")).result(binding))
    end
  end
end
```

can be used as:

```sh
rake 'api:doc:html[v1, api/v1/docs, https://production.byinfinum.co]'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/infinum/mina-dox. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mina::Dox project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/mina-dox/blob/master/CODE_OF_CONDUCT.md).
