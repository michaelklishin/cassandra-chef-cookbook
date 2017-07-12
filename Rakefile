require 'foodcritic'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

desc 'Run all lints'
task lint: %w[foodcritic rubocop]
task unit: %w[foodcritic rubocop spec]
task default: %w[foodcritic rubocop spec integration:vagrant]
task docker: %w[foodcritic rubocop spec integration:docker]

desc 'Run Rubocop Lint Task'
task :rubocop do
  RuboCop::RakeTask.new
end

desc 'Run FoodCritic Lint Task'
FoodCritic::Rake::LintTask.new do |fc|
  fc.options = {
    fail_tags: ['any']
  }
end

desc 'Run Chef Spec Test'
task :spec do
  RSpec::Core::RakeTask.new(:spec)
end

namespace :integration do
  desc 'Run integration tests with kitchen-vagrant'
  task :vagrant do
    require 'kitchen'
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new.instances.each do |instance|
      instance.test(:always)
    end
  end

  begin
    desc 'Run integration tests with kitchen-docker'
    task :docker do
      ENV['KI_DRIVER'] = 'docker'
      require 'kitchen'
      Kitchen.logger = Kitchen.default_file_logger
      Kitchen::Config.new.instances.each do |instance|
        instance.test(:always)
      end
    end
  rescue LoadError
    puts '>>>>> kitchen gem not loaded, omitting tasks' unless ENV['CI']
  end
end
