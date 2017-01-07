source 'https://rubygems.org'

gem 'buff-extensions', '1.0.0'
gem 'listen', '3.0.7'
gem 'ruby_dep', '1.3.1'

gem 'berkshelf'
gem 'chefspec'
gem 'dep_selector', '1.0.3'
gem 'foodcritic'
gem 'rake', '~> 10.0' # Rake 11 is not compatible with foodcritic
gem 'rubocop'

gem 'nokogiri', '= 1.6.1'

group :integration do
  gem 'guard', '~> 2.6'
  gem 'guard-foodcritic', '~> 1.0.3'
  gem 'guard-rspec', '~> 4.2'
  gem 'kitchen-docker'
  gem 'kitchen-vagrant'
  gem 'test-kitchen'
end

group :test do
  gem 'coveralls', require: false
end

group :development do
  gem 'chef'
  gem 'knife-spec'
  gem 'knife-spork', '~> 1.0.17'
  gem 'stove'
end

# Uncomment these lines if you want to live on the Edge:
#
# group :development do
#   gem "berkshelf", github: "berkshelf/berkshelf"
#   gem "vagrant", github: "mitchellh/vagrant", tag: "v1.6.3"
# end
#
# group :plugins do
#   gem "vagrant-berkshelf", github: "berkshelf/vagrant-berkshelf"
#   gem "vagrant-omnibus", github: "schisamo/vagrant-omnibus"
# end
