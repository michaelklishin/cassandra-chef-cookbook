#!/usr/bin/env rake

require 'foodcritic'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

desc 'Run all lints'
task :lint => %w(foodcritic rubocop)
task :default => :spec

desc 'Run Rubocop Lint Task'
task :rubocop do
  puts "Running Rubocop Lint.."
  RuboCop::RakeTask.new
end

desc 'Run Food Critic Lint Task'
task :foodcritic do
  puts "Running Food Critic Lint.."
  FoodCritic::Rake::LintTask.new do |fc|
    fc.options = {:fail_tags => ['correctness']}
  end
end

desc 'Run Chef Spec Test'
task :spec do
  RSpec::Core::RakeTask.new(:spec)
end
