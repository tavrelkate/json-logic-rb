#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

source_dir = ARGV[0] || '/tmp/compat-tables/suites'
out_file = ARGV[1] || File.expand_path('../spec/tmp/tests.json', __dir__)

index_file = File.join(source_dir, 'index.json')
abort("index.json not found at #{index_file}") unless File.exist?(index_file)

index = JSON.parse(File.read(index_file))
merged = []

index.each do |relative_path|
  suite_file = File.join(source_dir, relative_path)
  abort("suite file not found: #{suite_file}") unless File.exist?(suite_file)

  merged << "# suite: #{relative_path}"
  suite_entries = JSON.parse(File.read(suite_file))
  suite_entries.each { |entry| merged << entry }
end

File.write(out_file, JSON.pretty_generate(merged) + "\n")
case_count = merged.count { |entry| entry.is_a?(Hash) && entry.key?('rule') }
puts "Wrote #{out_file} with #{case_count} rule cases from #{index.size} suites"
