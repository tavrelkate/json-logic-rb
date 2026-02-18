# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Or < JsonLogic::LazyOperation
  def self.name = "or"

  def call(args, data)
    raise JsonLogic::InvalidArgumentsError.new unless args.is_a?(Array)
    return false if args.empty?

    args.each do |a|
      v = JsonLogic.apply(a, data)
      return v if !!v
    end

    JsonLogic.apply(args.last, data)
  end
end
