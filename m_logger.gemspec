# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "m_logger"
  spec.version = "1.0.0"
  spec.authors = ["Takumasa Ochi"]

  spec.summary = "Simple Logger with Alternative Log Rotation Strategy"
  spec.description = "Simple Logger with Alternative Log Rotation Strategy"
  spec.homepage = "https://github.com/DeNA/m_logger"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # spec.metadata["allowed_push_host"] = ""

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/DeNA/m_logger"
  spec.metadata["changelog_uri"] = "https://github.com/DeNA/m_logger/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "logger"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
