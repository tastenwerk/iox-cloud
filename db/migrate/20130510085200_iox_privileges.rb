class IoxPrivileges < ActiveRecord::Migration
  def change
    create_table :iox_privileges do |t|

      t.boolean :can_write, default: false
      t.boolean :can_delete, default: false
      t.boolean :can_share, default: false

      t.integer :created_by
      t.integer :updated_by

      t.belongs_to :user
      
      t.timestamps
    end
  end
end