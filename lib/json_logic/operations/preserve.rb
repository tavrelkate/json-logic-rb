# frozen_string_literal: true

class JsonLogic::Operations::Preserve < JsonLogic::LazyOperation
  def self.name = "preserve"

  def call(args, _data) = args.is_a?(Array) ? args : [args]
end
