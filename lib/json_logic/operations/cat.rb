# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Cat < JsonLogic::Operation
  def self.name = "cat"

  def call(args, _data) = args.map! { |v| stringify(v) }.join

  private

  # Arithmetic returns Floats (1 + 2 is 3.0). Print whole numbers without
  # the ".0", like JavaScript does: "Total: 3", not "Total: 3.0".
  def stringify(v)
    if v.is_a?(Float) && v.finite? && v == v.truncate && v.abs < 1e21
      v.to_i.to_s
    else
      v.to_s
    end
  end
end
