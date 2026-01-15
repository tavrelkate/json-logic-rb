# frozen_string_literal: true

require_relative 'semantics'
require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/deep_dup'

module JsonLogic
  class Engine
    include Semantics

    def self.default
      @default ||= new(registry: Registry.new)
    end

    def initialize(registry:)
      @registry = registry
    end

    attr_reader :registry

    def evaluate(rule, data = nil)
      apply rule, data.deep_dup.then { |d| d.respond_to?(:with_indifferent_access) ? d.with_indifferent_access : d }
    end

    private

    def apply(rule, data)
      case rule
      when Numeric,
           String,
           TrueClass,
           FalseClass,
           NilClass
        rule
      when Array
        rule.map { |r| apply(r, data) }
      when Hash
        name, raw_args = rule.first
        op_class = @registry.fetch(name)
        raise ArgumentError, "unknown operation: #{name}" unless op_class

        args =
          case raw_args
          when nil   then []
          when Array then raw_args
          else            [raw_args]
          end

        if op_class.values_only?
          values = args.map { |a| apply(a, data) }
          op_class.new.call(values, data)
        else
          op_class.new.call(args, data)
        end
      else
        rule
      end
    end
  end
end
