class CreateProfilesTable < ActiveRecord::Migration
  def self.up
    create_table :profiles, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :name, :string
      t.column :story, :text
      t.column :source_flickr_photo_url, :text
      t.column :via_flickr_photo_url, :text
      t.column :via_other, :string
    end
  end

  def self.down
    drop_table :profiles
  end
end