# frozen_string_literal: true

require "logger"

require_relative "m_logger/version"
require_relative "m_logger/log_device"

class MLogger < ::Logger
  # rubocop:disable Lint/MissingSuper,Metrics/MethodLength,Metrics/ParameterLists
  def initialize(logdev, shift_age = 0, shift_size = 1_048_576, level: DEBUG,
                 progname: nil, formatter: nil, datetime_format: nil,
                 binmode: false, shift_period_suffix: "%Y%m%d")
    self.level = level
    self.progname = progname
    @default_formatter = Formatter.new
    self.datetime_format = datetime_format
    self.formatter = formatter
    @logdev = nil
    @level_override = {}

    return unless logdev && logdev != File::NULL

    # Only this part is different from original ::Logger
    @logdev = if RUBY_VERSION >= "2.7.0"
                MLogger::LogDevice.new(logdev,
                  shift_age: shift_age,
                  shift_size: shift_size,
                  shift_period_suffix: shift_period_suffix,
                  binmode: binmode
                )
              else
                MLogger::LogDevice.new(logdev,
                  shift_age: shift_age,
                  shift_size: shift_size,
                  shift_period_suffix: shift_period_suffix
                )
              end
  end
  # rubocop:enable Lint/MissingSuper,Metrics/MethodLength,Metrics/ParameterLists
end
