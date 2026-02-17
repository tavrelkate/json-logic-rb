# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Try < JsonLogic::LazyOperation
  def self.name = "try"

  def call(args, data)
    args = args.is_a?(Array) ? args : [args]
    last_error = nil
    context = data

    args.each do |expr|
      begin
        value = JsonLogic.apply(expr, context)
        if value.is_a?(Float) && value.nan?
          last_error = JsonLogic::NaNError.new
          context = last_error.payload
          next
        end
        return value
      rescue JsonLogic::LogicError => e
        last_error = e
        context = e.payload
      rescue ArgumentError, IndexError, TypeError, NoMethodError
        last_error = JsonLogic::InvalidArgumentsError.new
        context = last_error.payload
      rescue ZeroDivisionError, FloatDomainError
        last_error = JsonLogic::NaNError.new
        context = last_error.payload
      rescue StandardError => e
        last_error = JsonLogic::LogicError.new(e.message)
        context = last_error.payload
      end
    end

    raise(last_error || JsonLogic::InvalidArgumentsError.new)
  end
end
