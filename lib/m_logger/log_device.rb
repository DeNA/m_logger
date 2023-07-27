# frozen_string_literal: true

require "logger"

class MLogger
  class LogDevice < ::Logger::LogDevice
    def initialize(log = nil, *args, shift_period_suffix: nil, **kwargs)
      # When the output is file, save original name, and append shift_period_suffix.
      is_file = log && !(log.respond_to?(:write) && log.respond_to?(:close))
      if is_file
        @original_filename = log
        log = m_logger_filename(shift_period_suffix)
      end

      super(log, *args, shift_period_suffix: shift_period_suffix, **kwargs)
    end

    private

    def check_shift_log
      # Switch to a new file, when the time has come.
      return unless @filename && @filename < (f = m_logger_filename(@shift_period_suffix))

      reopen(f)
    end

    def add_log_header(_file)
      # skip writing log header
    end

    def m_logger_filename(suffix)
      "#{@original_filename}.#{Time.now.strftime(suffix)}"
    end
  end
end
