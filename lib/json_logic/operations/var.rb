# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Var < JsonLogic::Operation
  def self.name = "var"
  def self.values_only? = false

  def call(args, data)
    json = JsonLogic::Tree.new(data)

    if args.is_a?(Array)
      path_rule = args[0]
      fallback_rule = args[1]
    else
      path_rule = args
      fallback_rule = nil
    end

    path = JsonLogic.apply(path_rule, data)
    if path.is_a?(String) && path.empty?
      return data[""] if data.is_a?(Hash) && data.key?("")
      return data
    end

    return json.dig(path, split_dots: true) if json.exists?(path, split_dots: true)

    return nil if fallback_rule.nil?

    JsonLogic.apply(fallback_rule, data)
  end
end
