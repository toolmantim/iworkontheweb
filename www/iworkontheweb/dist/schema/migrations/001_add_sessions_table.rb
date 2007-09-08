class AddSessionsTable < ActiveRecord::Migration
  def self.up
    create_table :sessions, :force => true do |t|
        t.column :session_id, :string,  :limit => 32
        t.column :created_at, :datetime
        t.column :data,       :text
    end
     add_index "sessions", ["session_id"], :name => "session_id_index"
  end

  def self.down
    drop_table :sessions
  end
end
