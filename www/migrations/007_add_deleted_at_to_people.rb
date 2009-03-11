class AddDeletedAtToPeople < ActiveRecord::Migration
  def self.up
    add_column :iworkontheweb_people, :deleted_at, :datetime
  end
  def self.down
    remove_column :iworkontheweb_people, :deleted_at
  end
end
