# Testing

## Install Dependencies

First install dependencies with

    bundle install

## Test Suites

This cookbook contains several test suites, each with its own Rake task:

 * `rake lint` will run Rubocop and Food Critic
 * `rake unit` will run unit tests
 * `rake integration:vagrant` will run integration tests in a local Vagrant VM (and thus requires VirtualBox or Vagrant VMware plugin to be installed)
 * `rake integration:docker` will run integration tests in a Docker contains (and thus requires Docker to be installed)
