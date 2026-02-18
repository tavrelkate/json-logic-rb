# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Substr < JsonLogic::Operation
  def self.name = "substr"

  def call((string, index, length), _data)
    value = string.to_s
    start = index.to_i
    start += value.length if start.negative?
    start = start.clamp(0, value.length)

    return value[start..] || "" if length.nil?

    size = length.to_i
    return value.slice(start, size) || "" unless size.negative?

    finish = (value.length + size).clamp(start, value.length)
    value.slice(start...finish) || ""
  end
end
