require 'iworkontheweb'

Iworkontheweb.establish_db_connection

require 'rexml/document'
require 'open-uri'

class Iworkontheweb::FlickrFetcher
  API_KEY = "11f5a2f3ae888c99f2da5a8c70411584"
  LIMIT = 500

  class Photo < Struct.new(:id, :title, :secret, :server, :date_upload, :date_taken, :machine_tags, :sizes)
    def sizes
      @sizes ||= mapped_sizes
    end

    protected
      def get_sizes
        REXML::Document.new open("http://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=#{API_KEY}&photo_id=#{self.id}")
      end
      def mapped_sizes
        get_sizes.get_elements("//size").map do |e|
          Size.new(*%w(label width height source url).map {|a| e.attributes[a]})
        end
      end
  end

  class Size < Struct.new(:label, :width, :height, :source, :url)
  end

  def poll!
    mapped_iwotw_tagged_photos
  end

  protected
    def get_iwotw_tagged_photos
      REXML::Document.new open("http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=#{API_KEY}&extras=date_upload,date_taken,machine_tags&per_page=#{LIMIT}&machine_tags=iworkontheweb:name=&sort=date-posted-asc")
    end
    def mapped_iwotw_tagged_photos
      get_iwotw_tagged_photos.get_elements("//photo").map do |e|
        photo = Photo.new(*%w(id title secret server dateupload datetaken).map {|a| e.attributes[a]})
        photo.machine_tags = e.attributes["machine_tags"].split(" ").inject({}) do |hash,tag|
          hash[tag.split("=")[0]] = tag.split("=")[1]
          hash
        end
        photo
      end      
    end
end

puts Iworkontheweb::FlickrFetcher.new.poll!.inspect