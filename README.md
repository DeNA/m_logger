# MLogger

MLogger is a simple logger featuring an alternative log rotation strategy, specially designed to handle high traffic loads and transient environments.

To use MLogger, initiate a new logger with `MLogger.new('log/production.log', shift_period_suffix: '%Y%m%d_%H')`.

## Log Rotation Strategy

Here's how ordinary log rotation strategy works:

1. Logs are consistently written to the same file (e.g., `production.log`).
2. The file is renamed once a specified time or size limit is reached (e.g., `production.log` becomes `production.log.20230701`).

In contrast, MLogger employs a different log rotation strategy:

1. Each log message is written to a time-stamped file (e.g., `production.log.20230701_11`).
2. Upon reaching a time threshold, logging is switched to a new file with the updated timestamp (e.g., `production.log.20230701_12`).

Key advantages of using MLogger include:

1. Support for hourly and shorter shift periods, accommodating heavy traffic loads.
2. Log lines always exist within the appropriately time-stamped path, even in cases where there are no logs or when there is an overflow of logs beyond shift periods.

## Additional Features

1. For systems expecting an IO-like interface, you can utilize `MLogger::LoggerDevice` (`MLogger::LoggerDevice#write`).
2. To facilitate line-based operations, MLogger skips writing a log header (e.g., `# Logfile created on %s by %s`).

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add m_logger

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install m_logger

## Usage

```ruby
# Log to File
hourly_logger = MLogger.new('log/my_log', shift_period_suffix: '%Y%m%d_%H') # hourly rotate
hourly_logger.debug('fuga')

daily_logger = MLogger.new('log/my_log', shift_period_suffix: '%Y%m%d') # daily rotate
daily_logger.debug('fuga')

# Log in Rack::Middleware
logger_device = MLogger::Device.new('log/rack_ltsv', shift_period_suffix: '%Y%m%d_%H')
Rails.configuration.middleware.insert(0, Rack::LtsvLogger, logger_device)

# Log to Stdout (You don't have to change logger class.)
logger = MLogger.new(STDOUT)
logger.info('hoge')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/DeNA/m_logger. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/DeNA/m_logger/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MLogger project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/DeNA/m_logger/blob/master/CODE_OF_CONDUCT.md).

## Special Thanks

External log file specification originates from Mobage and Sakasho series in DeNA.
Thanks for those who have contributed to these products.
