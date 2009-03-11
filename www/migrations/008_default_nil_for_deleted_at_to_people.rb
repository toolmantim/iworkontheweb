class DefaultNilForDeletedAtToPeople < ActiveRecord::Migration
  def self.up
    remove_column :iworkontheweb_people, :deleted_at
    add_column :iworkontheweb_people, :deleted_at, :datetime, :default => nil
  end
  def self.down
  end
end
