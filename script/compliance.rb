# frozen_string_literal: true

require_relative '../lib/json_logic'
require 'json'

SUITES = {
  "compliance_v1" => File.expand_path("../spec/tmp/v1/tests.json", __dir__),
  "compliance_v2" => File.expand_path("../spec/tmp/v2/tests.json", __dir__),
  "original" => File.expand_path("../spec/tmp/v1/tests.json", __dir__),
  "new" => File.expand_path("../spec/tmp/v2/tests.json", __dir__)
}.freeze

def usage!
  puts <<~USAGE
    Usage:
      ruby script/compliance.rb [compliance_v1|compliance_v2|all|PATH]

    Examples:
      ruby script/compliance.rb compliance_v1
      ruby script/compliance.rb compliance_v2
      ruby script/compliance.rb all
      ruby script/compliance.rb spec/tmp/v2/tests.json
  USAGE
  exit 1
end

def extract_case(node)
  if node.is_a?(Array) && [2, 3].include?(node.size) && (node[0].is_a?(Hash) || node[0].is_a?(Array))
    rule, a2, a3 = node
    data, expected = (node.size == 2 ? [nil, a2] : [a2, a3])
    return { rule: rule, data: data, expected: expected, expected_error: nil, description: nil }
  end

  return unless node.is_a?(Hash) && node.key?("rule")

  expected = if node.key?("result")
               node["result"]
             elsif node.key?("expected")
               node["expected"]
             end

  {
    rule: node["rule"],
    data: node["data"],
    expected: expected,
    expected_error: node["error"],
    description: node["description"]
  }
end

def collect_cases(payload)
  cases = []
  stack = [payload]

  while (node = stack.pop)
    if (item = extract_case(node))
      cases << item
    elsif node.is_a?(Array)
      node.size == 2 && node[0].is_a?(String) && node[1].is_a?(Array) ? stack << node[1] : node.each { |e| stack << e }
    elsif node.is_a?(Hash)
      node.each_value { |v| stack << v }
    end
  end

  cases.reverse
end

def run_suite(label, path)
  abort("#{label}: tests file not found at #{path}") unless File.exist?(path)

  payload = JSON.parse(File.read(path))
  cases = collect_cases(payload)
  abort("#{label}: no tests found in #{path}") if cases.empty?

  total = 0
  failed = 0

  cases.each_with_index do |c, i|
    rule = c[:rule]
    data = c[:data]
    expected = c[:expected]
    expected_error = c[:expected_error]
    description = c[:description]
    total += 1
    case_label = description ? " #{description}" : ""

    if expected_error
      begin
        got = JsonLogic.apply(rule, data)
        next if expected_error["type"] == "NaN" && got.is_a?(Float) && got.nan?

        failed += 1
        puts "[FAIL ##{i + 1}]#{case_label} expected_error=#{expected_error.inspect} got=#{got.inspect} rule=#{rule.inspect} data=#{data.inspect}"
      rescue StandardError => e
        got_type =
          if e.respond_to?(:payload) && e.payload.is_a?(Hash) && e.payload["type"]
            e.payload["type"]
          else
            e.message.to_s
          end

        next if got_type == expected_error["type"]

        failed += 1
        puts "[ERROR ##{i + 1}]#{case_label} expected_error=#{expected_error.inspect} got_error=#{got_type.inspect} rule=#{rule.inspect} data=#{data.inspect}"
      end
    else
      begin
        got = JsonLogic.apply(rule, data)
        next if got == expected
        next if expected.is_a?(Float) && expected.nan? && got.is_a?(Float) && got.nan?

        failed += 1
        puts "[FAIL ##{i + 1}]#{case_label} exp=#{expected.inspect} got=#{got.inspect} rule=#{rule.inspect} data=#{data.inspect}"
      rescue StandardError => e
        failed += 1
        puts "[ERROR ##{i + 1}]#{case_label} #{e.class}: #{e.message} rule=#{rule.inspect} data=#{data.inspect}"
      end
    end
  end

  passed = total - failed
  percent = total.zero? ? 100.0 : (passed * 100.0 / total)
  puts "#{label}: #{passed}/#{total} passed (#{format('%.2f', percent)}%)"
  { label: label, passed: passed, total: total, failed: failed }
end

arg = ARGV[0]
usage! if %w[-h --help].include?(arg)

targets = case arg
          when nil then ["compliance_v2"]
          when "all" then ["compliance_v1", "compliance_v2"]
          else [arg]
          end

results = targets.map do |target|
  path = SUITES[target] || target
  run_suite(target, path)
end

if results.size > 1
  passed = results.sum { |r| r[:passed] }
  total = results.sum { |r| r[:total] }
  percent = total.zero? ? 100.0 : (passed * 100.0 / total)
  puts "total: #{passed}/#{total} passed (#{format('%.2f', percent)}%)"
end

exit(results.any? { |r| r[:failed].positive? } ? 1 : 0)
