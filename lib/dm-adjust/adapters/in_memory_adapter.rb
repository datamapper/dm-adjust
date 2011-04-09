module DataMapper
  module Adapters
    module InMemoryAdapterAdjust
      def adjust(attributes, collection)
        attributes = attributes_as_fields(attributes)
        read(collection.query).each do |record|
          record.update(attributes) do |key, oldvalue, newvalue|
            (oldvalue || 0) + newvalue
          end
        end.size
      end
    end # module InMemoryAdapterAdjust

    extendable do
      # @api private
      def const_added(const_name)
        if(const_name == :InMemoryAdapter)
          InMemoryAdapter.send(:include, InMemoryAdapterAdjust)
        end

        super
      end
    end
  end # module Adapters
end # module DataMapper
