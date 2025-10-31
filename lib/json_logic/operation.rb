# frozen_string_literal: true

module JsonLogic
  class Operation
    include Semantics

    def self.op_name = nil

    def self.values_only? = true

    # Implement in subclasses.
    def call(args, data)
      raise NotImplementedError
    end
  end
end
