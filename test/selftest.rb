#!/usr/bin/env ruby
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'json_logic'

def t(name)
  print "[TEST] #{name} ... "
  puts(yield ? 'OK' : 'FAIL')
end

t('add') { JsonLogic.apply({ '+' => [1, 2, 3] }) == 6.0 }
t('ge + var') { JsonLogic.apply({ '>=' => [{ 'var' => 'age' }, 18] }, { 'age' => 20 }) == true }
t('and short-circuit') { JsonLogic.apply({ 'and' => [false, { '/' => [1, 0] }] }) == false }
t('map inc') do
  JsonLogic.apply({ 'map' => [{ 'var' => 'xs' }, { "+": [{ "var": '' }, 1] }] }, { 'xs' => [1, 2, 3] }) == [2, 3, 4]
end

t('unrecognized operation raises with its name') do
  JsonLogic.apply({ 'unknown_operation' => [1, 2] })
  false
rescue JsonLogic::UnrecognizedOperationError => e
  e.message == 'Unrecognized Operation: "unknown_operation"'
end

t('unrecognized operation nested inside a lazy op still raises') do
  JsonLogic.apply({ 'if' => [true, { 'nested_unknown_operation' => 1 }, 2] })
  false
rescue JsonLogic::UnrecognizedOperationError => e
  e.message == 'Unrecognized Operation: "nested_unknown_operation"'
end
