module Resque
  module Plugins
    module DataWarehouse

      module Fact
        def self.find(type, values)
          klass = "Facts::#{type}Fact".constantize
          fact = klass.send(:find, values["id"]) rescue nil
          fact = klass.new if fact.nil?
          fact.id = values["id"]
          values.delete("id")
          values.delete_if{|key,value| !fact.attribute_names.include?(key)}
          values.each do |k,v|
            fact[k] = v
          end
          fact
        end
      end

    end
  end
end
