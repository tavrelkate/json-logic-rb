class JsonLogic::EnumerableOperation < JsonLogic::LazyOperation
  def call(args, data)
    raise JsonLogic::InvalidArgumentsError.new unless args.is_a?(Array) && args.size >= 2
    raise JsonLogic::InvalidArgumentsError.new if args[0].nil?

    items, rule = extract_items_and_rule(args, data)
    raise JsonLogic::InvalidArgumentsError.new unless items.is_a?(Array)

    call_with_values(evaluate_values(items, rule, data))
  end

  protected

  def call_with_values(_values)
    raise NotImplementedError
  end

  def extract_items_and_rule(rules, data)
    items_rule, rule = rules
    items = JsonLogic.apply(items_rule, data)
    [items, rule]
  end

  def evaluate_values(items, rule, data)
    return [] if rule.nil?

    items.each_with_index.map do |item, index|
      JsonLogic.apply(rule, JsonLogic::Scope.new(item, data, index))
    end
  end
end
