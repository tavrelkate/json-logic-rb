# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Sub < JsonLogic::Operation
  def self.name = "-"

  def call(args, _data)
    raise JsonLogic::InvalidArgumentsError.new if args.empty?
    numbers = args.map(&:to_f)
    numbers.one? ? -numbers.first : numbers.drop(1).reduce(numbers.first, :-)
  end
end
