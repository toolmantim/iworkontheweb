class RenameHeightAndWidthToImageHeightAndWidth < ActiveRecord::Migration
  def self.up
    rename_column :iworkontheweb_people, :height, :image_height
    rename_column :iworkontheweb_people, :width, :image_width
  end
  def self.down
    rename_column :iworkontheweb_people, :image_height, :height
    rename_column :iworkontheweb_people, :image_width, :width
  end
end