# frozen_string_literal: true

module JsonLogic
  # Per-item evaluation scope for enumerable operations.
  # Keeps meta-fields virtual so they are not written into item hashes.
  class Scope < Hash
    ROOT_KEY = ""
    VALUE_KEY = "value"
    INDEX_KEY = "index"
    PARENT_KEY = "__parent__"
    SCOPE_KEY = "__scope__"

    def initialize(item, parent, index)
      super()
      update(item) if item.is_a?(Hash)
      @item = item
      @parent = parent
      @index = index
    end

    def [](key)
      normalized = normalize_key(key)
      return @parent if normalized == PARENT_KEY
      return true if normalized == SCOPE_KEY

      if super_key?(normalized)
        super(normalized)
      else
        virtual_value(normalized)
      end
    end

    def key?(key)
      normalized = normalize_key(key)
      return true if normalized == PARENT_KEY || normalized == SCOPE_KEY
      return true if normalized == ROOT_KEY || normalized == VALUE_KEY || normalized == INDEX_KEY
      return true if super_key?(normalized)

      !virtual_value(normalized).nil?
    end

    private

    def normalize_key(key)
      case key
      when Symbol then key.to_s
      else key
      end
    end

    def super_key?(key)
      hash_has_key?(key) || (key.is_a?(String) && hash_has_key?(key.to_sym))
    end

    def hash_has_key?(key)
      Hash.instance_method(:key?).bind_call(self, key)
    end

    def virtual_value(key)
      return @item if key == ROOT_KEY
      return @item if key == VALUE_KEY
      return @index if key == INDEX_KEY

      nil
    end
  end
end
