# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Exists < JsonLogic::Operation
  def self.name = "exists"
  def self.values_only? = false

  def call(args, data) = JsonLogic::Tree.new(data).exists?(normalize_path(args, data), split_dots: false)

  private

  def normalize_path(args, data) = args.is_a?(Array) ? args.as_array.map { |part| JsonLogic.apply(part, data) } : JsonLogic.apply(args, data)
end
