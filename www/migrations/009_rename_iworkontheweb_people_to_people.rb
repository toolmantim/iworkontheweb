class RenameIworkonthewebPeopleToPeople < ActiveRecord::Migration
  def self.up
    rename_table :iworkontheweb_people, :people
  end
  def self.down
    rename_table :people, :iworkontheweb_people
  end
end

