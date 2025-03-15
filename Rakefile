# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  desc 'RuboCop not available'
  task :rubocop do
    puts 'RuboCop is disabled'
  end
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files = ['lib/**/*.rb']
    t.options = ['--no-private', '--protected']
    t.stats_options = ['--list-undoc']
  end
rescue LoadError
  desc 'YARD not available'
  task :yard do
    puts 'YARD is disabled'
  end
end

task default: [:spec, :rubocop]