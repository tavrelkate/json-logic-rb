# frozen_string_literal: true

require_relative 'json_logic/version'
require_relative 'json_logic/semantics'
require_relative 'json_logic/operation'
require_relative 'json_logic/lazy_operation'
require_relative 'json_logic/enumerable_operation'
require_relative 'json_logic/registry'
require_relative 'json_logic/engine'

module JsonLogic
  module Operations
  end
end


# Load operation classes (each file defines one class with .op_name)
Dir[File.join(__dir__, 'json_logic', 'operations', '*.rb')].sort.each { |f| require f }

# Auto-register all operation classes with .op_name
module JsonLogic
  module Loader
    module_function

    def register_all!(registry)
      ObjectSpace.each_object(Class) do |klass|
        next unless klass < JsonLogic::Operation
        next unless klass.respond_to?(:op_name) && klass.op_name && !klass.op_name.to_s.empty?

        registry.register(klass)
      end
    end
  end

  class << self
    def apply(rule, data = nil)
      Engine.default.evaluate(rule, data)
    end
  end
end

JsonLogic::Loader.register_all!(JsonLogic::Engine.default.registry)
