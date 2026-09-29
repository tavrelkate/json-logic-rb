# frozen_string_literal: true

class JsonLogic::Operations::All < JsonLogic::EnumerableOperation
  def self.name = "all"

  protected

  def call_with_values(values)
    !values.empty? && values.all? { |value| !!value }
  end
end
