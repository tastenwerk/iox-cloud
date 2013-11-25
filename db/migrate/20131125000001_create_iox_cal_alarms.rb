class CreateIoxCalAlarms < ActiveRecord::Migration
  def change
    create_table :iox_cal_alarm do |t|

      t.string        :name

      t.datetime      :starts_at, index: true
      t.string        :alarm_type, index: true

      t.belongs_to    :user
      t.belongs_to    :event
      
      t.timestamps

    end
  end
end