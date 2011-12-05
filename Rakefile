require 'rake'
require 'bundler'
require 'rspec/core/rake_task'

namespace :gem do
  Bundler::GemHelper.install_tasks
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

