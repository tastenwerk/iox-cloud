module IoxCloud
  # Provides helper methods that can be used in migrations.
  module Schema
    COLUMNS = { :name         => :string, 
                :access       => [ :integer, { default: 1 } ],
                :public_access_expires   => :date,
                :public_key   => :string,
                :created_at   => :integer,
                :updated_by   => :integer }

    def self.included(base)
      ActiveRecord::ConnectionAdapters::Table.send :include, TableDefinition
      ActiveRecord::ConnectionAdapters::TableDefinition.send :include, TableDefinition
      ActiveRecord::ConnectionAdapters::AbstractAdapter.send :include, Statements
      ActiveRecord::Migration::CommandRecorder.send :include, CommandRecorder
    end

    module Statements
      def add_cloud_container(table_name)
        COLUMNS.each_pair do |column_name, column_arr|
          add_column(table_name, "#{column_name}", 
                                  IoxCloud::Schema.get_column_type(column_arr), 
                                  IoxCloud::Schema.get_column_opts(column_arr) )
        end
      end

      def remove_cloud_container(table_name)
        COLUMNS.each_pair do |column_name, column_type|
          remove_column(table_name, "#{column_name}")
        end
      end

    end

    module TableDefinition
      def cloud_container
        COLUMNS.each_pair do |column_name, column_arr|
          column("#{column_name}",
                  IoxCloud::Schema.get_column_type(column_arr), 
                  IoxCloud::Schema.get_column_opts(column_arr) )
        end
      end
    end

    module CommandRecorder
      def add_cloud_container(*args)
        record(:add_attachment, args)
      end

      private

      def invert_add_cloud_container(args)
        [:remove_attachment, args]
      end
    end

    def self.get_column_type( column_arr )
      return column_arr.is_a?(Array) ? column_arr[0] : column_arr
    end

    def self.get_column_opts( column_arr )
      return column_arr.is_a?(Array) ? column_arr[1] : {}
    end

  end
end
