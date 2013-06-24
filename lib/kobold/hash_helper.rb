class HashHelper
  def self.project_keys(hash_in, keys)
    hash_out = {}
    keys.each do |key|
      passes = false
      if block_given?
        passes = hash_in.key?(key) && yield(key, hash_in[key])        
      else
        passes = hash_in.key?(key)
      end
      if passes
        hash_out[key] = hash_in[key]
      end
    end
    return hash_out
  end
  
  def self.choose_alternative_key(hash_in, keys_with_other_names)
    keys_with_other_names.each do |key, alternative_keys|
      if !hash_in.key?(key)
        alternative_keys.each do |alternative_key|
          if hash_in.key?(alternative_key)
            hash_in[key] = hash_in[alternative_key]
            break
          end
        end
      end
    end
    return hash_in
  end

  def self.safe_merge(hash_one, hash_two)
    hash_to_return = {}
    hash_two.each do |k, v|
      key = k
      while hash_to_return.key?(key)
        key = '_' + key 
      end
      hash_to_return[key] = v
    end

    hash_one.each do |k, v|
      key = k
      while hash_to_return.key?(key)
        key = '_' + key 
      end
      hash_to_return[key] = v
    end
    return hash_to_return
  end

  def self.flatten(to_flatten, namespace='')
    flattened = {}
    if to_flatten.kind_of?(Hash)
      to_flatten.each do |k, v|
        flattened_key = namespace.empty? ? k : "#{namespace}_#{k}"
        flattened = self.safe_merge(flattened, self.flatten(v, flattened_key))
      end
    elsif to_flatten.kind_of?(Array)
      index = 0
      to_flatten.each do |element|
        flattened_key = "#{namespace}_#{index}"
        flattened = self.safe_merge(flattened, self.flatten(element, flattened_key))
        index += 1
      end
    else
      flattened[namespace] = to_flatten
    end

    return flattened
  end

  def self.symbolize_keys(hash)
    new_hash = {}
    hash.each do |key, value| 
      symbolized_key = key.to_sym rescue key
      new_hash[symbolized_key] = hash[key]
    end
    return new_hash
  end
end
