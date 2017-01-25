source 'https://rubygems.org'

gem 'buff-extensions', '2.0.0'
gem 'listen', '3.1.5'
gem 'ruby_dep', '1.5.0'

gem 'berkshelf'
gem 'chefspec'
gem 'foodcritic'
gem 'rake'
gem 'rubocop'

gem 'nokogiri', '= 1.6.8.1'

group :integration do
  gem 'guard', '~> 2.6'
  gem 'guard-foodcritic', '~> 2.1.0'
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
