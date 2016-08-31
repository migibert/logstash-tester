# coding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "rspec/expectations"
require 'json'

# Load the test cases
filter_data = Dir[File.join(File.dirname(__FILE__), '../filter_data/**/*.json')]

# Load the logstash filter config files
files = Dir[File.join(File.dirname(__FILE__), '../filter_config/*.conf')]
@@configuration = String.new
files.sort.each do |file|
  @@configuration << File.read(file)
end


def run_case(tcase, fields, ignore, only, data_file, i)
  input = fields
  in_key = tcase['in_key']
  if in_key.nil?
    input['message'] = tcase['in']
  else
    input[in_key] = tcase['in']
  end

  msg_header = "[#{File.basename(data_file)}##{i}]"

  sample(input) do
    expected = tcase['out']
    expected_fields = expected.keys

    # Handle no results (for example, when a line is voluntarily dropped)
    lsresult = results.any? ? results[0] : {}
    result_fields = lsresult.to_hash.keys.select { |f| not ignore.include?(f) }
    unless only.nil?
      result_fields = result_fields.select { |f| only.include?(f) }
    end
    formated_json = JSON.pretty_generate(lsresult.to_hash)

    # TODO test for grokparsefailures

    # Test for presence of expected fields
    missing = expected_fields.select { |f| not result_fields.include?(f) }
    msg = "\n#{msg_header} Fields missing in logstash output: #{missing}\nComplete logstash output: #{formated_json}\n--"
    expect(missing).to be_empty, msg

    # Test for absence of unknown fields
    extra = result_fields.select { |f| not expected_fields.include?(f) }
    msg = "\n#{msg_header} Unexpected fields in logstash output: #{extra}\nComplete logstash output: #{formated_json}\n--"
    expect(extra).to be_empty, msg

    # Test individual field values
    expected.each do |name,value|
      msg = "\n#{msg_header} Field value mismatch: '#{name}'\nExpected: #{value} (#{value.class})\nGot: #{lsresult[name]} (#{lsresult[name].class})\n\n--"
      expect(lsresult[name].to_s).to eq(value.to_s), msg
    end
  end
end

filter_data.each do |data_file|
  # Count test cases in this file
  test_case = JSON.parse(File.read(data_file))

  (0..(test_case['cases'].length-1)).each do |i|
    describe "#{File.basename(data_file)}##{i}" do
      config(@@configuration)
      test_case = JSON.parse(File.read(data_file))
      run_case(test_case['cases'][i], test_case['fields'], test_case['ignore'], test_case['only'], data_file, i)
    end
  end
end

