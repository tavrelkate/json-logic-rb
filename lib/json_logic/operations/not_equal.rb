# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::NotEqual < JsonLogic::LazyOperation
  def self.name = "!="

  def call(args, data)
    raise JsonLogic::InvalidArgumentsError.new unless args.is_a?(Array) && args.size >= 2

    prev = JsonLogic.apply(args.first, data)
    args[1..].each do |arg|
      current = JsonLogic.apply(arg, data)
      return false if prev == current

      prev = current
    end
    true
  end
end
