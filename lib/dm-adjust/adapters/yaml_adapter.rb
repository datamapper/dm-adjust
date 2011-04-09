module DataMapper
  module Adapters
    module YamlAdapterAdjust
      def adjust(attributes, collection)
        attributes = attributes_as_fields(attributes)

        update_records(collection.model) do |records|
          records_to_update = collection.query.filter_records(records.dup)
          records_to_update.each do |record|
            record.update(attributes) do |key, oldvalue, newvalue|
              (oldvalue || 0) + newvalue
            end
          end.size
        end
      end
    end # module YamlAdapterAdjust

    extendable do
      # @api private
      def const_added(const_name)
        if const_name == :YamlAdapter
          YamlAdapter.send(:include, YamlAdapterAdjust)
        end

        super
      end
    end
  end # module Adapters
end # module DataMapper
