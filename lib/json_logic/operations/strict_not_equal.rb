# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::StrictNotEqual < JsonLogic::LazyOperation
  def self.name = "!=="

  def call(args, data)
    raise JsonLogic::InvalidArgumentsError.new unless args.is_a?(Array) && args.size >= 2

    prev = JsonLogic.apply(args.first, data)
    args[1..].each do |arg|
      current = JsonLogic.apply(arg, data)
      return false if strict_equal_value?(prev, current)

      prev = current
    end
    true
  end

  private

  def strict_equal_value?(left, right)
    if left.is_a?(Numeric) && right.is_a?(Numeric)
      left.to_f == right.to_f
    elsif left.is_a?(Array) || left.is_a?(Hash)
      left.equal?(right)
    else
      left.class == right.class && left.eql?(right)
    end
  end
end
