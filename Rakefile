require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/*/*_spec.rb'
end

# require 'rspec-puppet/rake_task'

# begin
#   if Gem::Specification::find_by_name('puppet-lint')
#     require 'puppet-lint/tasks/puppet-lint'
#     PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "vendor/**/*.pp"]
#     task :default => [:rspec, :lint]
#   end
# rescue Gem::LoadError
#   task :default => :rspec
# end
