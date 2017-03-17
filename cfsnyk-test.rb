#!/usr/bin/env ruby

require 'json'
require 'tmpdir'

target_app = ARGV[0]
target_file = ARGV[1]
raise 'usage: app_name target_file' if [target_app].any?(&:nil?)

apps_payload = JSON.parse(`cf curl /v2/apps`)
app_metadata = apps_payload
  .fetch('resources')
  .detect { |el| el['entity']['name'] == target_app }
app_guid = app_metadata['metadata']['guid']

Dir.mktmpdir do |dir|
  Dir.chdir(dir) do
    `cf curl /v2/apps/#{app_guid}/droplet/download | tar -x`

    Dir.chdir('./app') do
      puts `snyk test --file=#{target_file} --json`
    end
  end
end
