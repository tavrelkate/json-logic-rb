# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Mod < JsonLogic::Operation
  def self.name = "%"

  def call(args, _data)
    raise JsonLogic::InvalidArgumentsError.new if args.size < 2
    numbers = args.map(&:to_f)
    numbers.drop(1).reduce(numbers.first) do |result, divisor|
      result - divisor * (result / divisor).truncate
    end
  end
end
