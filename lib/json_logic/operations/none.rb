# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::None < JsonLogic::EnumerableOperation
  def self.name = "none"

  protected

  def call_with_values(values)
    values.none? { |value| !!value }
  end
end
