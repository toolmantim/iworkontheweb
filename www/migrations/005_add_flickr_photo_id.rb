class AddFlickrPhotoId < ActiveRecord::Migration
  def self.up
    add_column :iworkontheweb_people, :flickr_photo_id, :string
  end
  def self.down
    remove_column :iworkontheweb_people, :flickr_photo_id, :string
  end    
end
