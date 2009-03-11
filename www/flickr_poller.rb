__DIR__ = File.dirname(__FILE__)

require "#{__DIR__}/models"

require "#{__DIR__}/parallel"

require 'rexml/document'
require 'open-uri'

class FlickrPoller
  API_KEY = "11f5a2f3ae888c99f2da5a8c70411584"
  API_URL_BASE = "http://api.flickr.com/services/rest"
  LIMIT = 500
  MAX_THREADS = 10

  class Photo < Struct.new(:id, :farm, :server, :secret, :description, :posted_timestamp, :last_update_timestamp, :photo_page_url, :tags, :machine_tags)

    class Size < Struct.new(:label, :width, :height, :source, :url); end

    class MachineTag < Struct.new(:namespace, :predicate, :value)
      def self.from_s(string)
        new($1, $2, $3) if string =~ /(.*)\:(.*)\=(.*)/
      end
    end
  
    def self.from_photo_info(e)
      photo = Photo.new(*%w(id farm secret server).map {|a| e.attributes[a]})
      photo.description = e.get_elements("description").first.text
      photo.posted_timestamp = e.get_elements("dates").first.attributes["taken"].to_i
      photo.last_update_timestamp = e.get_elements("dates").first.attributes["lastupdate"].to_i
      photo.machine_tags = e.get_elements("//tag[@machine_tag='1']").map {|mtag| Photo::MachineTag.from_s(mtag.attributes["raw"])}
      photo.photo_page_url = e.get_elements("//url[@type='photopage']").first.text
      photo      
    end
  
    def self.iwotw_name_tagged_photos
      flickr_api_result(get_tagged_photos_url).get_elements("//photo").parallel_map(MAX_THREADS) do |e|
        from_photo_info flickr_api_result(get_info_url(e.attributes["id"])).get_elements("//photo").first
      end
    end
  
    def sizes
      @sizes ||= self.class.flickr_api_result(get_sizes_url).get_elements("//size").map do |e|
        Size.new(*%w(label width height source url).map {|a| e.attributes[a]})
      end
    end
  
    def to_person_attributes
      {
        "name" => name_tag.value,
        "story" => description,
        "source_flickr_photo_url" => photo_page_url,
        "image_source_url" => medium_size.source,
        "image_width" => medium_size.width.to_i,
        "image_height" => medium_size.height.to_i,
        "flickr_photo_id" => id
      }
    end

    def medium_size
      sizes.find {|s| s.label == "Medium"}
    end
    def name_tag
      machine_tags.find {|tag| tag.namespace == "iworkontheweb" && tag.predicate == "name"}
    end
    def to_s
      "#{id}: #{name_tag.value}"
    end
      
    protected
      def get_sizes_url
        "#{API_URL_BASE}/?method=flickr.photos.getSizes&api_key=#{API_KEY}&photo_id=#{self.id}"
      end
      def self.get_info_url(photo_id)
        "#{API_URL_BASE}/?method=flickr.photos.getInfo&api_key=#{API_KEY}&photo_id=#{photo_id}"
      end
      def self.get_tagged_photos_url
        "#{API_URL_BASE}/?method=flickr.photos.search&api_key=#{API_KEY}&per_page=#{LIMIT}&machine_tags=iworkontheweb:name=&sort=date-posted-asc"
      end
      def self.get_lisas_profile_photo_dammit_url
        get_tagged_photos_url + "&user_id=#{LISAS_USER_ID}"
      end
      def self.flickr_api_result(url)
        response = open(url).read
        IWOTW_LOGGER.debug "Fetching #{url} returned:\n#{response}"
        parsed_response = REXML::Document.new(response)
        if (stat = parsed_response.get_elements("//rsp").first.attributes["stat"]) != "ok"
          IWOTW_LOGGER.error %(Flickr returned <rsp stat="#{stat}">:\n #{parsed_response.to_s})
          raise %(Flickr returned <rsp stat="#{stat}">)
        end
        parsed_response
      end
  end

  def self.update!
    people = Person.find(:all, :select => 'id, name, flickr_photo_id, deleted_at', :conditions => 'deleted_at IS NULL')
    IWOTW_LOGGER.info "#{people.length} existing people in the DB"
  
    flickr_photos = Photo.iwotw_name_tagged_photos
    IWOTW_LOGGER.info "#{flickr_photos.length} tagged Flickr Photos"

    if flickr_photos.empty?
      IWOTW_LOGGER.error "Flickr returned no photos!"
      return
    end
  
    deleted_people = people.find_all {|person| !flickr_photos.any? {|photo| photo.id == person.flickr_photo_id }}
    IWOTW_LOGGER.info "#{deleted_people.length} people no longer on Flickr (#{deleted_people.map(&:name).join(', ')})"
    delete_people_no_longer_with_photos(deleted_people) unless deleted_people.empty?
  
    existing_photos = flickr_photos.find_all {|photo| people.any? {|person| person.flickr_photo_id == photo.id }}
    IWOTW_LOGGER.info "#{existing_photos.length} photos on Flickr already in DB (#{existing_photos.map(&:to_s).join(', ')})"
    update_people_from_flickr_photos(existing_photos) unless existing_photos.empty?

    new_photos = flickr_photos.find_all {|photo| !people.any? {|person| person.flickr_photo_id == photo.id}}
    IWOTW_LOGGER.info "#{new_photos.length} new photos on Flickr (#{new_photos.map(&:to_s).join(', ')})"
    add_people_from_flickr_photos(new_photos) unless new_photos.empty?
  end

  def self.update_people_from_flickr_photos(flickr_photos)
    IWOTW_LOGGER.debug "Updating #{flickr_photos.length} existing people"
    flickr_photos.parallel_map(MAX_THREADS) do |photo|
      [photo, photo.to_person_attributes]
    end.each do |(photo, person_attributes)|
      Person.find_by_flickr_photo_id(photo.id).update_attributes_if_changed!(person_attributes)
    end
  end
  def self.add_people_from_flickr_photos(new_flickr_photos)
    IWOTW_LOGGER.debug "Adding #{new_flickr_photos.length} people from new flickr photos (#{new_flickr_photos.map(&:id).join(',')})"
    new_flickr_photos.each do |photo|
      previously_deleted_peep = Person.find_by_flickr_photo_id(photo.id)
      if previously_deleted_peep
        previously_deleted_peep.update_attributes_if_changed!(photo.to_person_attributes)
        previously_deleted_peep.update_attribute(:deleted_at, nil)
      else
        Person.new(photo.to_person_attributes).save!
      end
    end
  end
  def self.delete_people_no_longer_with_photos(people)
    IWOTW_LOGGER.debug "Deleting #{people.length} people no longer with flickr photos (#{people.map(&:name).join(',')})"
    people.each {|p| p.update_attribute(:deleted_at, Time.now) }
  end
end

if $0 == __FILE__
  FlickrPoller.update!
end