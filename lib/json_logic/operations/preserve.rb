# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Preserve < JsonLogic::LazyOperation
  def self.name = "preserve"

  def call(args, _data) = args.is_a?(Array) ? args : [args]
end
