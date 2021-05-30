require 'json'

class Object
  def to_hash_object
    hash = {}
    instance_variables.each do |variable|
      key_name = variable.to_s.delete('@')
      value = instance_variable_get(variable)
      hash[key_name] = value.instance_variables.length.positive? ? value.to_hash_object : value
    end
    hash
  end
end