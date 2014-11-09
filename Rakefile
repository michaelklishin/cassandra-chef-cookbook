#!/usr/bin/env rake

require 'foodcritic'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

desc 'Run all lints'
task :lint => %w(foodcritic rubocop knife spec)
task :default => :lint

desc 'Run Rubocop Lint Task'
task :rubocop do
  puts "Running Rubocop Lint.."
  RuboCop::RakeTask.new
end

desc 'Run Food Critic Lint Task'
task :foodcritic do
  puts "Running Food Critic Lint.."
  FoodCritic::Rake::LintTask.new do |fc|
    fc.options = {:fail_tags => ['any']}
  end
end

desc 'Run Knife Cookbook Test Task'
task :knife do
  puts "Running Knife Check.."
  current_dir = File.expand_path(File.dirname(__FILE__))
  cookbook_dir = File.dirname(current_dir)
  cookbook_name = File.basename(current_dir)
  sh "bundle exec knife cookbook test -o #{cookbook_dir} #{cookbook_name}"
end

desc 'Run Chef Spec Test'
task :spec do
  RSpec::Core::RakeTask.new(:spec)
end
