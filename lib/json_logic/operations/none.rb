# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::None < JsonLogic::EnumerableOperation
  def self.name = "none"

  def call(args, data)
    items, rule_applied_to_each_item = resolve_items_and_per_item_rule(args, data, nil_items_invalid: true)
    !rule_applied_to_each_item || items.each_with_index.none? do |item, idx|
      !!(JsonLogic.apply(rule_applied_to_each_item, scoped_item_data(item, data, idx)))
    end
  end
end
