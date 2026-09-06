# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::MissingSome < JsonLogic::Operation
  def self.name = "missing_some"

  def call((min_ok, list), data)
    json = JsonLogic::Tree.new(data)
    keys = list.as_array
    missing = keys.select { |key| json.dig(key).nil? }
    (keys.size - missing.size) >= min_ok ? [] : missing
  end
end
