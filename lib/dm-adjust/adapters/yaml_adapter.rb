module DataMapper
  module Adapters
    class YamlAdapter < AbstractAdapter
      def adjust(attributes, collection)
        query = collection.query

        attributes = attributes_as_fields(attributes)
        update_records(collection.model) do |records|
          records_to_update = collection.query.filter_records(records.dup)
          records_to_update.each do |record|
            adjusted_attributes = adjust_attributes(attributes, record)
            record.update(adjusted_attributes)
          end.size
        end
      end

      private

      def adjust_attributes(attributes, record)
        properties = record.reject { |key, val| !attributes.keys.include?(key) }
        updated = attributes.merge(properties) { |key, old, new| old + new }
        record.update(updated)
      end
    end
  end
end
