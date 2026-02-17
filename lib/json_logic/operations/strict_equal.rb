# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::StrictEqual < JsonLogic::LazyOperation
  def self.name = "==="

  def call(args, data)
    raise JsonLogic::InvalidArgumentsError.new unless args.is_a?(Array) && args.size >= 2

    prev = JsonLogic.apply(args.first, data)
    args[1..].each do |arg|
      current = JsonLogic.apply(arg, data)
      if prev.is_a?(Numeric) && current.is_a?(Numeric)
        return false unless prev.to_f == current.to_f
      else
        return false unless prev.class == current.class && prev == current
      end

      prev = current
    end
    true
  end
end
