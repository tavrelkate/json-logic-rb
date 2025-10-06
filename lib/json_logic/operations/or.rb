# frozen_string_literal: true
class JsonLogic::Operations::Or < JsonLogic::LazyOperation
  def self.op_name = "or"

  def call(args, data)
    args.each do |a|
      v = JsonLogic.apply(a, data)
      return v if JsonLogic::Semantics.truthy?(v)
    end
    args.empty? ? nil : JsonLogic.apply(args.last, data)
  end
end
