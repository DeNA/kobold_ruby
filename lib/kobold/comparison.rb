module ComparisonHelper

  #Assert that any keys that are present in the first hash exist and map to the same values in the second hash.
  def existing_keys_match(expected_hash, actual_hash)
    expected_values = {}
    actual_values = {}
    expected_hash.keys.each do |key|
      
      if expected_hash.key?(key.to_s)
        expected_value = expected_hash[key.to_s]
      elsif expected_hash.key?(key.to_sym)
        expected_value = expected_hash[key.to_sym]
      else
        expected_value = :missing
      end
      
      if actual_hash.key?(key.to_s)
        actual_value = actual_hash[key.to_s]
      elsif actual_hash.key?(key.to_sym)
        actual_value = actual_hash[key.to_sym]
      else
        actual_value = :missing
      end
      
      if expected_value == :dontcare
        if (actual_value.nil? || actual_value == :missing)
          expected_values[key] = expected_value
          actual_values[key] = actual_value
        end
      elsif expected_value == :missing
        if actual_hash.key?(key)
          expected_values[key] = expected_value
          actual_values[key] = actual_value
        end
        
      elsif expected_value.class == Hash && actual_value.class == Hash
        sub_expected_values, sub_actual_values = existing_keys_match(expected_value, actual_value)
        if !sub_expected_values.empty?
          expected_values[key] = sub_expected_values
          actual_values[key] = sub_actual_values
        end
      elsif expected_value.class == Array && actual_value.class == Array
        sub_expected_values, sub_actual_values = list_compare(expected_value, 
                                                              actual_value,
                                                              {:hash => :existing,
                                                               :list => :existing})
        if !(sub_expected_values.empty? && sub_actual_values.empty?)
          expected_values[key] = sub_expected_values
          actual_values[key] = sub_actual_values
        end
      else
        if (expected_value != actual_value)
          expected_values[key] = expected_value
          actual_values[key] = actual_value
        end
      end
    end
    
    return [expected_values, actual_values]
  end

  def get_hash_differences(expected_hash, actual_hash, dont_care_keys=[])
    if expected_hash.class == String
      expected_hash = JSON.parse(expected_hash)
    end
    
    if actual_hash.class == String
      actual_hash = JSON.parse(actual_hash)
    end
    
    all_keys = Set.new([expected_hash.keys, actual_hash.keys].flatten.map{|key| key.to_s})
    expected_values = {}
    actual_values = {}
    
    all_keys.each do |key|

      if expected_hash.key?(key.to_s)
        expected_value = expected_hash[key.to_s]
      elsif expected_hash.key?(key.to_sym)
        expected_value = expected_hash[key.to_sym]
      else
        expected_value = :missing
      end
      
      if actual_hash.key?(key.to_s)
        actual_value = actual_hash[key.to_s]
      elsif actual_hash.key?(key.to_sym)
        actual_value = actual_hash[key.to_sym]
      else
        actual_value = :missing
      end

      if expected_value == :dontcare || dont_care_keys.include?(key.to_sym) || dont_care_keys.include?(key.to_s)
        if actual_value.nil? || actual_value == :missing
          expected_values[key] = expected_value
          actual_values[key] = actual_value
        end
      elsif (expected_value.class == Hash && actual_value.class == Hash)
        sub_hash_expected_values, sub_hash_actual_values = self.get_hash_differences(expected_value, actual_value)
        if !sub_hash_expected_values.empty?
          expected_values[key] = sub_hash_expected_values
          actual_values[key] = sub_hash_actual_values
        end
      elsif (expected_value.class == Array && actual_value.class == Array)
        sub_expected_values, sub_actual_values = list_compare(expected_value,
                                                              actual_value)
        if !(sub_expected_values.empty? && sub_actual_values.empty?)
          expected_values[key] = sub_expected_values
          actual_values[key] = sub_actual_values
        end
      else
        if !expected_value.eql?(actual_value)
          expected_values[key] = expected_value
          actual_values[key] = actual_value
        end
      end
    end
    
    return [expected_values, actual_values]
  end

  def self.ordered_list_compare(expected_list, actual_list, type_compare={})
    if expected_list.size != actual_list.size
      return [expected_list, actual_list]
    else
      expected_elements = ListDiff.new([])
      actual_elements = ListDiff.new([])
      i = 0
    end

    while i < expected_list.size
      expected_value = expected_list[i]
      actual_value = actual_list[i]
      match = true
      result = compare(expected_value, actual_value, type_compare)
      if result == :match
        expected_elements.push_match
        actual_elements.push_match
      else
        expected_sub, actual_sub = result
        expected_elements.push(expected_sub)
        actual_elements.push(actual_sub)
      end

      i += 1
    end
    if expected_elements.empty? && actual_elements.empty?
      return :match
    else
      return [expected_elements.display, actual_elements.display]
    end
  end

  def ordered_list_compare(*args)
    ComparisonHelper.ordered_list_compare(*args)
  end


  def self.unordered_list_compare(expected_list, actual_list, type_compare={})
    missing_expected_indexes = *0...expected_list.size
    missing_actual_indexes = *0...actual_list.size
    i = 0
    while i < expected_list.size
      expected_element = expected_list[i]
      missing_actual_indexes.each do |j|
        actual_element = actual_list[j]
        result = compare(expected_element, actual_element, type_compare)
        if result == :match
          missing_expected_indexes.delete(i)
          missing_actual_indexes.delete(j)
          break
        end
      end
      i += 1
    end
    
    #We've matched all the items that we could from one list to the other.  
    #Now we build two ListDiffs (which shows matching and non-matching positions in the list),
    #which are returned
    expected_return = ListDiff.new([])
    actual_return = ListDiff.new([])
    expected_list.size.times do |i|
      if missing_expected_indexes.include?(i)
        expected_return.push(expected_list[i])
      else
        expected_return.push_match()
      end
    end

    actual_list.size.times do |j|
      if missing_actual_indexes.include?(j)
        actual_return.push(actual_list[j])
      else
        actual_return.push_match()
      end
    end

    if expected_return.empty? && actual_return.empty?
      return :match
    else
      return [expected_return.display, actual_return.display]
    end
  end

  def unordered_list_compare(*args)
    ComparisonHelper.unordered_list_compare(*args)
  end
  
  def self.list_compare(expected_list, actual_list, type_compare={})
    default_type_compare = {:hash => :full,
                            :list => :full,
                            :ordered => true}
    type_compare = default_type_compare.merge(type_compare)
    
    if type_compare[:ordered]
      result = ordered_list_compare(expected_list, actual_list, type_compare)
    else
      result = unordered_list_compare(expected_list, actual_list, type_compare)
    end

    return result
  end

  def list_compare(*args)
    ComparisonHelper.list_compare(*args)
  end

  def self.hash_compare(expected_hash, actual_hash, type_compare)
    default_type_compare = {:hash => :full,
                            :list => :full,
                            :dontcare_keys => [],
                            :ordered => true}
    type_compare = default_type_compare.merge(type_compare)
    expected_hash = HashWithIndifferentGet.new(expected_hash)
    actual_hash = HashWithIndifferentGet.new(actual_hash)
    if expected_hash.key?("__compare")
      __compare = expected_hash["__compare"]
      if __compare.is_a?(Hash)
        type_compare = default_type_compare.merge(expected_hash["__compare"])
      elsif expected_hash["__compare"].is_a?(Symbol)
        type_compare[:hash] = __compare 
        type_compare[:list] = __compare
      end
      expected_hash.delete("__compare")
    end
    expected_return = {}
    actual_return = {}

    if type_compare[:hash] == :full
      keys = Set.new([expected_hash.keys, actual_hash.keys].flatten.map {|key| key.to_sym})
    elsif type_compare[:hash] == :existing
      keys = expected_hash.keys
    end

    keys.each do |key|
      if type_compare[:dontcare_keys].include?(key.to_s) || type_compare[:dontcare_keys].include?(key.to_sym)
        result = compare(:dontcare, actual_hash[key], type_compare)
      else
        result = compare(expected_hash[key], actual_hash[key], type_compare)
      end
      if result != :match
        expected_sub, actual_sub = result
        expected_return[key] = expected_sub
        actual_return[key] = actual_sub
      end
    end
    
    if expected_return.empty? and actual_return.empty?
      return :match
    else
      return [expected_return, actual_return]
    end
  end

  def hash_compare(*args)
    ComparisonHelper.hash_compare(*args)
  end

  def self.compare(expected, actual, type_compare={})
    default_type_compare = {:hash => :full,
                            :list => :full,
                            :ordered => true}
    type_compare = default_type_compare.merge(type_compare)

    if expected == :dontcare
      expected = ComparisonHelper::DontCare.new(:rule => :not_nil_or_missing)
    end

    if expected.class == ComparisonHelper::DontCare
      if expected.compare_with(actual)
        return :match
      else
        return ["dontcare: #{expected.rule}", actual]
      end
    elsif (!expected.is_a?(actual.class) && !actual.is_a?(expected.class))
      return [expected, actual]
    elsif expected.is_a?(Hash) || expected.is_a?(HashWithIndifferentGet)
      return hash_compare(expected, actual, type_compare)
    elsif expected.is_a?(Array)
      return list_compare(expected, actual, type_compare)
    else
      if expected == actual
        return :match
      else
        return [expected, actual]
      end
    end
  end

  def compare(*args)
    ComparisonHelper.compare(*args)
  end
end

class ComparisonHelper::DontCare
  def initialize(options={})
    defaults = {:rule => :not_nil_or_missing}
    options = defaults.merge(options)
    @rule = options[:rule]
    @options = options
  end

  def rule
    @rule
  end

  def compare_with(other_thing)
    if @rule == :not_nil_or_missing
      return !other_thing.nil? && other_thing != :missing
    elsif @rule == :array
      if !other_thing.is_a?(Array)
        return false
      end

      if @options[:length]
        return other_thing.size == @options[:length]
      end

      return true
    elsif @rule == :json
      begin
        JSON.parse(other_thing)
        return true
      rescue
        return false 
      end
    elsif @rule == :iso8601_datetime
      begin
        DateTime.strptime(other_thing, "%Y-%m-%dT%H:%M:%S%z")
        return true
      rescue ArgumentError
        return false
      end
    elsif @rule == :no_rules
      return true
    end
  end
end

class HashWithIndifferentGet
  def initialize(wrapped_hash)
    @wrapped_hash = wrapped_hash
  end

  def method_missing(method_name, *args)
    return @wrapped_hash.send(method_name, *args)
  end

  def [](key)
    value_for_symbol = @wrapped_hash[key.to_sym]
    value_for_string = @wrapped_hash[key.to_s]
    if !value_for_symbol.nil? && !value_for_string.nil?
      return @wrapped_hash[key] 
    elsif !value_for_symbol.nil?
      return value_for_symbol
    elsif !value_for_string.nil?
      return value_for_string
    else
      return nil
    end
  end
end

#If we're talking about the diff between two lists, there are 2 different ways to think about it.
#Example: Two lists: [1, 2, 3] and [1, 4, 3]
#Way 1: The ListDiff contains only the elements of one list that didn't match in the other list.
#       So, we produce two ListDiffs: [[2], [4]].
#       Of course, if the two lists match, the ListDiffs are empty.
#Way 2: Display the elements that didn't match positionally
#       So, we produce [[_, 2, _], [_, 4, _]]
#       If the lists match, both diffs are entirely underscores.
#We want to have one object with both representations.  If we want to determine if the lists match,
#we call listDiff1.empty? (which uses the representation in Way 1).  But if we want to display the differences, 
#we want to display them positionally, so we use the representation in Way 2.
#
#So, this ListDiff "is a"(n) array.  The array that it is in a Way 1 array.  But it also "has a"(n) array.
#The array that it has is the Way 2 array.
class ListDiff < Array
  def initialize(arr)
    @with_positions = arr
    val = arr.select {|element| element != '_'}
    super(val)
  end

  def display
    return @with_positions
  end

  def push_match
    @with_positions.push("_") 
  end

  def push(value)
    super(value)
    @with_positions.push(value)
  end
end
