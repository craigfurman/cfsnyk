#!/usr/bin/env ruby

require 'json'
require 'pp'

apps_payload = JSON.parse(`cf curl /v2/apps`)

apps_by_space_url = apps_payload.fetch('resources').group_by do |app|
  app['entity']['space_url']
end

spaces_by_space_url = Hash[apps_by_space_url.keys.map do |space_url|
  [space_url, JSON.parse(`cf curl #{space_url}`)]
end]

spaces_by_org_url = spaces_by_space_url.values.group_by do |space|
  space['entity']['organization_url']
end

spaces_by_org_url.each do |org_url, spaces|
  org_name = JSON.parse(`cf curl #{org_url}`)['entity']['name']
  puts org_name
  spaces.each do |space|
    puts "  #{space['entity']['name']}"
    apps_by_space_url[space['metadata']['url']].each do |app|
      puts "    - #{app['entity']['name']} (#{app['metadata']['guid']})"
    end
  end
end