class IoxCloudContainers < ActiveRecord::Migration
  def change
    create_table :iox_cloud_containers do |t|

      t.cloud_container
      t.timestamps
      
    end
  end
end