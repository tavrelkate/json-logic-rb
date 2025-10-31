# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::And < JsonLogic::LazyOperation
  def self.op_name = "and"

  def call(args, data)
    last = nil
    args.each do |a|
      last = JsonLogic.apply(a, data)
      return last unless !!last
    end
    last
  end
end
