class JsonLogic::EnumerableOperation < JsonLogic::LazyOperation
  private

  def resolve_items_and_per_item_rule(rules, data, nil_items_invalid:)
    raise ArgumentError, "Invalid Arguments" unless rules.is_a?(Array) && rules.size >= 2

    rule_that_returns_items = rules[0]
    rule_applied_to_each_item = rules[1]
    items_value = JsonLogic.apply(rule_that_returns_items, data)
    raise ArgumentError, "Invalid Arguments" if nil_items_invalid && items_value.nil?
    items = Array(items_value)
    [items, rule_applied_to_each_item]
  end

  def scoped_item_data(item, data, index)
    base =
      if item.is_a?(Hash)
        item.dup
      else
        { "" => item }
      end

    base[""] = item unless base.key?("")
    base["index"] = index unless base.key?("index")
    base["value"] = item unless base.key?("value")
    base["__parent__"] = data
    base["__scope__"] = true
    base
  end
end
