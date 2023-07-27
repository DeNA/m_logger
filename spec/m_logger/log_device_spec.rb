# frozen_string_literal: true

require "pathname"
require "tmpdir"

require "timecop"

RSpec.describe MLogger::LogDevice do
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

  describe "#write" do
    it "can directly write to the file" do
      Timecop.freeze(Time.local(1996, 12, 25, 12, 34))

      log_device = MLogger::LogDevice.new(tmp_path.join("access_log"), shift_period_suffix: "%Y%m%d_%H")
      log_device.write("this is access log")

      expect(tmp_path.join("access_log.19961225_12").read).to eq "this is access log"
    end
  end
end
