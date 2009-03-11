require 'activerecord'

__DIR__ = File.dirname(__FILE__)

ActiveRecord::Base.logger = IWOTW_LOGGER
ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.establish_connection(
  {
    :development => {
      "adapter" => "sqlite3",
      "database" => "#{__DIR__}/iworkontheweb.db"
    },
    :production => {
      "adapter" => "sqlite3",
      "database" => "/var/www/iworkontheweb/iworkontheweb.db"
    }
  }[Sinatra::Application.environment]
)

ActiveRecord::Migrator.migrate("#{__DIR__}/migrations")

class Person < ActiveRecord::Base
  def self.latest
    find(:first, :order => 'created_at DESC', :conditions => 'deleted_at IS NULL')
  end
  def self.recent
    find(:all, :order => 'created_at DESC', :limit => 10, :select => 'id, name', :conditions => 'deleted_at IS NULL')
  end
  def self.all
    find(:all, :order => 'created_at ASC', :select => 'id, name', :conditions => 'deleted_at IS NULL')
  end
  def self.find_without_deleted(id)
    find(:first, :conditions => ['id = ? AND deleted_at IS NULL', id.to_i]) || raise(ActiveRecord::RecordNotFound)
  end
  def to_param
    "#{self.id}-#{self.name.downcase.gsub(' ','-').gsub(/[^a-z0-9-]/,'')}"
  end
  def formatted_story
    '<p>' +
      story.to_s.
      gsub(/\r\n?/, "\n").                     # \r\n and \r -> \n
      gsub(/\n\n+/, "</p>\n\n<p>").            # 2+ newline  -> paragraph
      gsub(/([^\n]\n)(?=[^\n])/, '\1<br />') + # 1 newline   -> br
    '</p>'
  end
  def update_attributes_if_changed!(new_attributes)
    if attributes.merge(new_attributes) != attributes
      update_attributes!(new_attributes)
    end
  end
end