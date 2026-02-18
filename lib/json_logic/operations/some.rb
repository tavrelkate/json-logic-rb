# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Some < JsonLogic::EnumerableOperation
  def self.name = "some"

  protected

  def call_with_values(values)
    !values.empty? && values.any? { |value| !!value }
  end
end
