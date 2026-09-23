# frozen_string_literal: true

class JsonLogic::Operations::Coalesce < JsonLogic::Operation
  def self.name = "??"

  def call(args, _data) = args.find { |v| !v.nil? }
end
