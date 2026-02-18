# frozen_string_literal: true

module JsonLogic
  class Tree
    INDEX_PATTERN = /\A-?\d+\z/

    def initialize(data)
      @data = data
    end

    def dig(path, split_dots: true)
      _found, value = lookup(path, split_dots: split_dots)
      value
    end

    def exists?(path, split_dots: true)
      lookup(path, split_dots: split_dots).first
    end

    private

    def lookup(path, split_dots: true)
      return [true, @data] if root_path?(path)

      current = @data
      each_segment(path, split_dots: split_dots).each do |segment|
        found, current = step(current, segment)
        return [false, nil] unless found
      end

      [true, current]
    end

    def root_path?(path)
      path.nil? || (path.is_a?(String) && path.empty?) || (path.is_a?(Array) && path.empty?)
    end

    def step(current, segment)
      case current
      when Hash
        fetch_from_hash(current, segment)
      when Array
        fetch_from_array(current, segment)
      else
        [false, nil]
      end
    end

    def fetch_from_hash(current, segment)
      key = find_hash_key(current, segment)
      return [false, nil] if key.nil?

      [true, current[key]]
    end

    def find_hash_key(current, segment)
      keys = [segment]
      keys << segment.to_sym if segment.is_a?(String)
      keys << segment.to_s
      keys.find { |key| current.key?(key) }
    end

    def fetch_from_array(current, segment)
      index = normalize_index(segment, current.length)
      return [false, nil] if index.nil?

      [true, current[index]]
    end

    def each_segment(path, split_dots: true)
      case path
      when Array
        path.flat_map { |segment| split_segment(segment, split_dots: split_dots) }
      else
        split_segment(path, split_dots: split_dots)
      end
    end

    def split_segment(segment, split_dots: true)
      if split_dots && segment.is_a?(String) && !segment.empty? && !segment.eql?(".")
        segment.split('.')
      else
        [segment]
      end
    end

    def normalize_index(segment, size)
      return nil unless segment.to_s.match?(INDEX_PATTERN)

      idx = segment.to_i
      idx += size if idx.negative?
      return nil if idx.negative? || idx >= size

      idx
    end
  end
end
