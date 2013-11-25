class IoxCloudStats < ActiveRecord::Migration
  def change
    create_table :iox_cloud_stats do |t|

      t.string :ip_addr
      t.string :user_agent
      t.string :os

      t.integer :views, default: 1
      t.integer :visits, default: 1

      t.string :lang

      t.belongs_to :cloud_container

      t.date :day, index: true

      t.timestamps
    end
  end
end
