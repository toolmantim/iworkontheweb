class AddHeightAndWidthToPeople < ActiveRecord::Migration
  def self.up
    add_column :iworkontheweb_people, :height, :integer
    add_column :iworkontheweb_people, :width,  :integer
  end
  def self.down
    remove_column :iworkontheweb_people, :height, :integer
    remove_column :iworkontheweb_people, :width,  :integer
  end
end
