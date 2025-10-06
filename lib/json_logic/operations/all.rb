# frozen_string_literal: true

class JsonLogic::Operations::All < JsonLogic::EnumerableOperation
  def self.op_name = "all"

  def call(args, data)
    items, rule_applied_to_each_item = resolve_items_and_per_item_rule(args, data)
    return false if items.empty?

    items.all? do |item|
      JsonLogic::Semantics.truthy?(
        JsonLogic.apply(rule_applied_to_each_item, item)
      )
    end
  end
end
