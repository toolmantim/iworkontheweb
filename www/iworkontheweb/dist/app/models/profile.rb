class Profile < ActiveRecord::Base
  def self.latest
    find(:all, :order => 'created_at DESC', :limit => 25)
  end
end