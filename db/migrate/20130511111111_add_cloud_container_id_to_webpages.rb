class AddCloudContainerIdToWebpages < ActiveRecord::Migration
  def change
    add_column :iox_webpages, :cloud_container_id, :integer
  end
end
