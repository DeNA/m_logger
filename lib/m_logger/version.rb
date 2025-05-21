# frozen_string_literal: true

require "logger"

class MLogger < ::Logger
  VERSION = "1.0.0" # This should be manually updated with m_logger.gemspec (gemspec cannot read this file because of `logger` dependency)
end
