class RemoveVias < ActiveRecord::Migration
  def self.up
    remove_column :iworkontheweb_people, :via_flickr_photo_url
    remove_column :iworkontheweb_people, :via_other
  end
  def self.down
    add_column :iworkontheweb_people, :via_flickr_photo_url,    :text
    add_column :iworkontheweb_people, :via_other,               :string
  end
end
