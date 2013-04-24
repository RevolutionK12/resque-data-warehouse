module Resque
  module Plugins
    module DataWarehouse
    	Dir[File.dirname(__FILE__) + '/data_warehouse/*.rb'].each{|g| require g}  
    	def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def warehoused
          after_commit :record_to_fact
          after_destroy :destroy_fact
        end
      end

      def record_to_fact
        DataWarehouse::Transaction.new.enqueue(self)
      end

      def destroy_fact
        DataWarehouse::Transaction.new.enqueue(self, 'delete')
      end

    end
  end
end
