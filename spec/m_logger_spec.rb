# frozen_string_literal: true

require "pathname"
require "tmpdir"
require "stringio"

require "timecop"
require "parallel"

# Since initialization timing of Logger and MLogger are critical, we intentionally avoid using let, before, and after.

RSpec.describe MLogger do
  let(:tmp_path) do
    Pathname.new(Dir.mktmpdir)
  end

  before do
    tmp_path
  end

  after do
    tmp_path.rmtree
    Timecop.return # Always return
  end

  describe "log file path" do
    context "without shift_period_suffix" do
      it "creates a file with default suffix" do
        Timecop.freeze(Time.local(1996, 12, 25))
        MLogger.new(tmp_path.join("production.log"))

        expect(tmp_path.children).to eq [tmp_path.join("production.log.19961225")]
      end
    end

    context "with shift_period_suffix" do
      it "creates a file with specified suffix" do
        Timecop.freeze(Time.local(1996, 12, 25, 12, 34, 56))
        MLogger.new(tmp_path.join("production.log"), shift_period_suffix: "%Y%m%d_%H")

        expect(tmp_path.children).to eq [tmp_path.join("production.log.19961225_12")]
      end
    end
  end

  describe "log header" do
    it "does not write header" do
      Timecop.freeze(Time.local(2023, 7, 1))
      MLogger.new(tmp_path.join("some_log"))

      expect(tmp_path.join("some_log.20230701").read.size).to eq 0
    end
  end

  describe "log rotation" do
    let(:simple_formatter) do
      lambda do |_severity, datetime, _progname, msg|
        datetime_str = datetime.strftime("%Y-%m-%d %H:%M:%S")
        "[#{datetime_str}] #{msg}\n"
      end
    end

    context "when time changes within the same period" do
      it "writes to the same log file" do
        Timecop.freeze(Time.local(2023, 7, 1, 16))
        logger = MLogger.new(tmp_path.join("production.log"), formatter: simple_formatter,
          shift_period_suffix: "%Y%m%d_%H"
        )

        logger.info("period begins")

        Timecop.freeze(Time.local(2023, 7, 1, 16, 59, 59))
        logger.info("period ends")

        expect(tmp_path.join("production.log.20230701_16").read).to eq <<~LOG
          [2023-07-01 16:00:00] period begins
          [2023-07-01 16:59:59] period ends
        LOG
      end
    end

    context "when time changes over periods" do
      it "writes to the appropriate log file" do
        Timecop.freeze(Time.local(2023, 7, 1, 16))
        logger = MLogger.new(tmp_path.join("production.log"), formatter: simple_formatter,
          shift_period_suffix: "%Y%m%d_%H"
        )

        logger.info("period begins")

        Timecop.freeze(Time.local(2023, 7, 1, 23))
        logger.info("new period begins")

        expect(tmp_path.join("production.log.20230701_16").read).to eq <<~LOG
          [2023-07-01 16:00:00] period begins
        LOG

        expect(tmp_path.join("production.log.20230701_23").read).to eq <<~LOG
          [2023-07-01 23:00:00] new period begins
        LOG
      end
    end

    context "when other shift-related options are specified" do
      it "ignores other options" do
        Timecop.freeze(Time.local(1996, 12, 25))
        logger = MLogger.new(tmp_path.join("production.log"), "daily", 1, shift_period_suffix: "%Y")

        logger.info("first log in 1996")

        Timecop.freeze(Time.local(1996, 12, 31))
        logger.info("last log in 1996")

        Timecop.freeze(Time.local(2022, 12, 25))
        logger.info("first log in 2022")

        expect(tmp_path.join("production.log.1996").read).to match(/first log in 1996/)
        expect(tmp_path.join("production.log.1996").read).to match(/last log in 1996/)
        expect(tmp_path.join("production.log.2022").read).to match(/first log in 2022/)
      end
    end
  end

  describe "thread-safe and process-safe" do
    let(:simple_formatter) do
      lambda do |_severity, datetime, _progname, msg|
        datetime_str = datetime.strftime("%Y-%m-%d %H:%M:%S")
        "[#{datetime_str}] #{msg}\n"
      end
    end

    context "when multiple thread writes (you can change threshold if this fails)" do
      it "writes correct logs" do
        items = (0...2000).to_a

        Timecop.travel(Time.local(2022, 12, 24, 23, 59, 59.99)) # 10ms to 12/25
        logger = MLogger.new(tmp_path.join("production.log"))

        Parallel.each(items, in_threads: 10) do |i|
          logger.info("#{"a" * 5000} #{i}")
        end

        previous_log = tmp_path.join("production.log.20221224")
        current_log = tmp_path.join("production.log.20221225")

        expect(previous_log.exist?).to be true
        expect(current_log.exist?).to be true

        written_numbers = []
        previous_log.each_line { |line| written_numbers << /a{5000} (\d+)\n$/.match(line)[1].to_i }
        current_log.each_line { |line| written_numbers << /a{5000} (\d+)\n$/.match(line)[1].to_i }

        expect(written_numbers.sort).to eq items
      end
    end

    context "when multiple process writes (you can change threshold if this fails)" do
      it "writes correct logs" do
        items = (0...2000).to_a

        Timecop.travel(Time.local(2022, 12, 24, 23, 59, 59.99)) # 10ms to 12/25
        logger = MLogger.new(tmp_path.join("production.log"))

        Parallel.each(items, in_processes: 10) do |i|
          logger.info("#{"a" * 5000} #{i}")
        end

        previous_log = tmp_path.join("production.log.20221224")
        current_log = tmp_path.join("production.log.20221225")

        expect(previous_log.exist?).to be true
        expect(current_log.exist?).to be true

        written_numbers = []
        previous_log.each_line { |line| written_numbers << /a{5000} (\d+)\n$/.match(line)[1].to_i }
        current_log.each_line { |line| written_numbers << /a{5000} (\d+)\n$/.match(line)[1].to_i }

        expect(written_numbers.sort).to eq items
      end
    end
  end

  describe "non-file logger" do
    context "with nil logger" do
      it "can be used as a logger" do
        logger = MLogger.new(nil)

        expect(logger.info("hoge")).to be true
      end
    end

    context "with IO object" do
      it "can be used as a logger" do
        sio = StringIO.new

        logger = MLogger.new(sio)
        logger.error("some log")

        expect(sio.tap(&:rewind).read).to match(/E, \[.+?\] ERROR -- : some log/)
      end
    end
  end
end
