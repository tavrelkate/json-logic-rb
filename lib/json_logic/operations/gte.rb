# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::GTE < JsonLogic::LazyOperation
  def self.name = ">="

  def call(args, data)
    raise JsonLogic::InvalidArgumentsError.new unless args.is_a?(Array) && args.size >= 2

    previous = JsonLogic.apply(args.first, data)
    args.drop(1).all? do |rule|
      current = JsonLogic.apply(rule, data)
      next false unless previous >= current

      previous = current
      true
    end
  end
end
