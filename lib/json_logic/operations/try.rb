# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Try < JsonLogic::LazyOperation
  def self.name = "try"

  def call(arguments, data)
    arguments = Array.wrap(arguments)
    raise JsonLogic::InvalidArgumentsError.new if arguments.empty?

    state = { data: data, error: nil }

    arguments.each do |expression|
      begin
        value = JsonLogic.apply(expression, state[:data])
        return value unless value.is_a?(Float) && value.nan?

        state[:error] = JsonLogic::NaNError.new
      rescue JsonLogic::Error => error
        state[:error] = error
      rescue ArgumentError, IndexError, TypeError, NoMethodError
        state[:error] = JsonLogic::InvalidArgumentsError.new
      rescue ZeroDivisionError, FloatDomainError
        state[:error] = JsonLogic::NaNError.new
      rescue StandardError => error
        state[:error] = JsonLogic::Error.new(error.message)
      end

      state[:data] = state[:error].payload
    end

    raise state[:error]
  end
end
