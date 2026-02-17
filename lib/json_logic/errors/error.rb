# frozen_string_literal: true

module JsonLogic
  class Error < StandardError
    DEFAULT_MESSAGE = "Error"

    attr_reader :type, :message, :payload

    def initialize(message = nil)
      @message = message_or_default(message)

      super(@message)
    end

    def payload
      { "type" => @message }
    end

    private

    def message_or_default(message)
      self.class < JsonLogic::Error || message.empty? ? default_message : message.to_s
    end

    def default_message
      self.class::DEFAULT_MESSAGE
    end
  end
end
