class AddImageSource < ActiveRecord::Migration
  def self.up
    add_column :iworkontheweb_people, :image_source_url, :text
  end
  def self.down
    remove_column :iworkontheweb_people, :image_source_url, :text
  end
end
