source 'https://rubygems.org'

gem 'rake'
gem 'berkshelf'
gem 'chefspec'
gem 'foodcritic'
gem 'rubocop'
gem 'dep_selector', '1.0.3'

group :integration do
  gem 'test-kitchen'
  gem 'kitchen-vagrant'
  gem 'guard', '~> 2.6'
  gem 'guard-rspec', '~> 4.2'
  gem 'guard-foodcritic', '~> 1.0.3'
end

group :test do
  gem 'coveralls', require: false
end

group :development do
  gem 'chef'
  gem 'knife-spork', '~> 1.0.17'
  gem 'knife-spec'
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
