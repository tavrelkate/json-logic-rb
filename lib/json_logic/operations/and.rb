# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::And < JsonLogic::LazyOperation
  def self.name = "and"

  def call(args, data)
    raise JsonLogic::InvalidArgumentsError.new unless args.is_a?(Array)

    args.reduce(false) do |_memo, rule|
      value = JsonLogic.apply(rule, data)
      break value unless value.to_bool
      value
    end
  end
end
