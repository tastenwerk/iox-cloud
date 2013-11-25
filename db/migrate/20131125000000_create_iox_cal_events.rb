class CreateIoxCalEvents < ActiveRecord::Migration
  def change
    create_table :iox_cal_events do |t|

      t.string        :name, required: true, index: true
      
      t.datetime      :starts_at, index: true
      t.datetime      :ends_at, index: true

      t.boolean       :all_day, index: true

      t.integer       :event_series_id, index: true

      t.text          :note
      t.string        :location
      t.float         :lat
      t.float         :lng

      t.iox_document_defaults
      t.timestamps

    end
  end
end