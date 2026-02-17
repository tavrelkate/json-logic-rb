# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Map < JsonLogic::EnumerableOperation
  def self.name = "map"

  def call(args, data)
    raise JsonLogic::InvalidArgumentsError.new unless args.is_a?(Array) && args.size >= 2
    raise JsonLogic::InvalidArgumentsError.new if args[0].nil? || args[1].nil?

    items, rule_applied_to_each_item = resolve_items_and_per_item_rule(args, data, nil_items_invalid: false)
    items.each_with_index.map do |item, idx|
      JsonLogic.apply(rule_applied_to_each_item, scoped_item_data(item, data, idx))
    end
  end
end
