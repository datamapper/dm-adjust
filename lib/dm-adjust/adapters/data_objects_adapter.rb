module DataMapper
  module Adapters
    module DataObjectsAdapterAdjust
      def adjust(attributes, collection)
        query = collection.query

        # TODO: if the query contains any links, a limit or an offset
        # use a subselect to get the rows to be updated

        properties  = []
        bind_values = []

        # make the order of the properties consistent
        query.model.properties(name).each do |property|
          next unless attributes.key?(property)
          properties  << property
          bind_values << attributes[property]
        end

        statement, conditions_bind_values = adjust_statement(properties, query)

        bind_values.concat(conditions_bind_values)

        execute(statement, *bind_values).affected_rows
      end

      module SQL
        private

        def adjust_statement(properties, query)
          conditions_statement, bind_values = conditions_statement(query.conditions)

          statement = "UPDATE #{quote_name(query.model.storage_name(name))}"
          statement << " SET #{set_adjustment_statement(properties)}"
          statement << " WHERE #{conditions_statement}" unless DataMapper::Ext.blank?(conditions_statement)

          return statement, bind_values
        end

        def set_adjustment_statement(properties)
          properties.map { |p| "#{quote_name(p.field)} = COALESCE(#{quote_name(p.field)}, 0) + ?" }.join(', ')
        end

      end # module SQL

      include SQL
    end # module DataObjectsAdapterAdjust

    extendable do
      # @api private
      def const_added(const_name)
        if const_name == :DataObjectsAdapter
          DataObjectsAdapter.send(:include, DataObjectsAdapterAdjust)
        end

        super
      end
    end

  end # module Adapters
end # module DataMapper
