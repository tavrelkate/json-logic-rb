# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Val < JsonLogic::Operation
  def self.name = "val"
  def self.values_only? = false

  def call(args, data)
    path = JsonLogic.apply(path_rule(args), data)
    return root_value(path, data) if root_path?(path)

    base, segments = resolve_base_and_segments(path, data)
    JsonLogic::Json.new(base).dig(segments, split_dots: false)
  end

  private

  def path_rule(args) = args.is_a?(Array) && args.one? ? args.first : args

  def root_path?(path)
    path.nil? || (path.is_a?(Array) && path.empty?) || (path.is_a?(String) && path.empty?)
  end

  def root_value(path, data)
    return data if path.nil?
    return scoped_root_value(data) if path.is_a?(Array) && path.empty?
    return data[""] if data.is_a?(Hash) && data.key?("")

    data
  end

  def scoped_root_value(data)
    return data[""] if data.is_a?(Hash) && data["__scope__"] && data.key?("")

    data
  end

  def resolve_base_and_segments(path, data)
    segments = path.is_a?(Array) ? path : [path]
    return [data, segments] unless segments.first.is_a?(Array)

    hop = segments.first.first.to_i
    [base_for_hop(data, hop), segments.drop(1)]
  end

  def base_for_hop(base, hop)
    return base if hop.zero?
    return base_for_positive_hop(base, hop) if hop.positive?

    (-hop - 1).times do
      parent = parent_of(base)
      break unless parent

      base = parent
    end
    base
  end

  def base_for_positive_hop(base, hop)
    moved = false
    (hop - 1).times do
      parent = parent_of(base)
      break unless parent

      base = parent
      moved = true
    end
    return base if moved

    stack = Thread.current[:json_logic_scope_stack] || []
    idx = stack.length - hop
    return base unless idx >= 0 && idx < stack.length

    stack[idx]
  end

  def parent_of(value) = value.is_a?(Hash) ? value["__parent__"] : nil
end
