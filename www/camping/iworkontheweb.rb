#!/usr/bin/env ruby

require 'rubygems'
require 'camping'
require 'camping/session'

Camping.goes :Iworkontheweb

IWOTW_LOGGER = ActiveRecord::Base.logger = Logger.new(STDOUT)

module Iworkontheweb
  LOGGER = 
  
  include Camping::Session
  
  # Method for other scripts to create a database connection. For example:
  #
  #   require 'iworkontheweb'
  #   Iworkontheweb.establish_db_connection
  #   puts Iworkontheweb::Models::Person.count
  def self.establish_db_connection
    Iworkontheweb::Models::Base.establish_connection({
      "development" => {
        "adapter" => "sqlite3",
        "database" => File.expand_path("~/.camping.db")
      }
    }[ENV["CAMPING_ENV"] || "development"])
  end
end

module Iworkontheweb::Models
  Base.default_timezone = :utc
  class Person < Base
    def self.latest
      find(:first, :order => 'created_at DESC')
    end
    def self.recent
      find(:all, :order => 'created_at DESC', :limit => 10, :select => 'id, name')
    end
    def self.all
      find(:all, :order => 'created_at ASC', :select => 'id, name')
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
  class CreateInitialTables < V 1.0
    def self.up
      create_table :iworkontheweb_people do |t|
        t.column :created_at,              :datetime
        t.column :updated_at,              :datetime
        t.column :name,                    :string
        t.column :story,                   :text
        t.column :source_flickr_photo_url, :text
        t.column :via_flickr_photo_url,    :text
        t.column :via_other,               :string
      end
    end
    def self.down
      drop_table :people
    end
  end
  class AddHeightAndWidthToPeople < V 2.0
    def self.up
      add_column :iworkontheweb_people, :height, :integer
      add_column :iworkontheweb_people, :width,  :integer
    end
    def self.down
      remove_column :iworkontheweb_people, :height, :integer
      remove_column :iworkontheweb_people, :width,  :integer
    end
  end
  class RenameHeightAndWidthToImageHeightAndWidth < V 3.0
    def self.up
      rename_column :iworkontheweb_people, :height, :image_height
      rename_column :iworkontheweb_people, :width, :image_width
    end
    def self.down
      rename_column :iworkontheweb_people, :image_height, :height
      rename_column :iworkontheweb_people, :image_width, :width
    end
  end
  class AddImageSource < V 4.0
    def self.up
      add_column :iworkontheweb_people, :image_source_url, :text
    end
    def self.down
      remove_column :iworkontheweb_people, :image_source_url, :text
    end
  end
  class AddFlickrPhotoId < V 5.0
    def self.up
      add_column :iworkontheweb_people, :flickr_photo_id, :string
    end
    def self.down
      remove_column :iworkontheweb_people, :flickr_photo_id, :string
    end    
  end
  class RemoveVias < V 6.0
    def self.up
      remove_column :iworkontheweb_people, :via_flickr_photo_url
      remove_column :iworkontheweb_people, :via_other
    end
    def self.down
      add_column :iworkontheweb_people, :via_flickr_photo_url,    :text
      add_column :iworkontheweb_people, :via_other,               :string
    end
  end
end

module Iworkontheweb::Controllers
  class Home < R '/'
    def get
      @body_class = "home"
      @person_count = Person.count
      @latest = Person.recent
      @person = Person.latest
      render :home
    end
  end
  class Show < R '/profiles/(\d+)', '/profiles/(\d+)-[a-z-]*'
    def get(id)
      @body_class = "show-profile"
      @person_count = Person.count
      @latest = Person.recent
      @person = Person.find(id)
      @page_title = "#{@person.name} - I work on the web."
      render :show
    rescue ActiveRecord::RecordNotFound
      @headers["Status"] = "404 Not Found"
      @page_title = "Page not found."
      render :not_found
    end
  end
  class Index < R '/profiles'
    def get
      @body_class = "all-profiles"
      @person_count = Person.count
      @latest = Person.recent
      @people = Person.all
      @page_title = %(All #{@person_count} I work on the web profiles)
      render :index
    end
  end
  class Info < R '/info/(\d+)', '/info/(\w+)/(\d+)', '/info', '/info/(\d+)/(\d+)/(\d+)/([\w-]+)'
    def get(*args)
      div do
        code args.inspect; br; br
        code @env.inspect; br
        code "Link: #{R(Info, 1, 2)}"
      end
    end
  end
  class Style < R '/iworkontheweb.css'
    def get
      @headers["Content-Type"] = "text/css; charset=utf-8"
      @body = %{
        html, body, div, p, ul, li, h1, h2 {
          margin: 0;
          padding: 0;
        }

        body {
          font: 14px/18px Georgia, serif;
          text-align: right;
          padding: 1em 5em 3em 1em;
        }

        .clear-both {
          clear: both;
        }

        .profile {
          float: right;
          text-align: left;
        }
        .navigation {
          float: right;
          margin-right: 20px;
          font-size: 12px;
          line-height: 20px;
        }
        .content-nav li {
          display: inline;
          margin-right: 0.5em;
        }        
        .skip-to-navigation {
          font-size: 12px;
        }
        .profile .skip-to-navigation {
          font-size: 14px;
        }
        
        p {
          margin: 1em 0;
        }

        a {
          color: #333;
        }

        a:hover {
          text-decoration: none;
          background-color: #000;
          color: #fff;
        }
        a:visited {
          color: #666;
        }

        h1, h2, h3 {
          font-weight: normal;
        }

        ul, li {
          list-style: none;
        }

        h1 {
          font-size: 48px;
          margin: 1em 0 20px 0;
        }
        
        h1 a, h1 a:visited, h1 a:hover {
          background-color: #fff;
          color: #000;
          text-decoration: none;
        }
        h1 a:hover {
          text-decoration: underline;
        }

        .profile h2 {
          font-size: 24px;
          text-align: right;
          margin-top: 15px;
        }
        
        .profile h2 a, .profile h2 a:hover, .profile h2 a:visited {
          text-decoration: none;
          background-color: #fff;
          color: #000;
        }
        .profile h2 a:hover {
          text-decoration: underline;
        }
        
        .profile .copy {
          margin-top: 15px;
        }
        
        .profile a img {
          border: 1px solid #000;
        }

        .navigation h2 {
          font-size: 16px;
          margin: 0;
          text-transform: lowercase;
          margin-bottom: 5px;
        }

        .all-profiles .profiles h2 {
          margin: 2em 0 0.5em 10%;
          text-align: left;
        }

        .skip-to-navigation a {
          color: #000;
        }

        .navigation .view-all {
          margin-top: 10px;  
        }

        .page, .all-profiles .profiles {
          width: 500px;
          float: right;
        }

        ul.group-1 {
          margin-left: 10%;
        }

        ul.group-1, ul.group-2, ul.group-3 {
          width: 30%;
          float: left;
          text-align: left;
        }
        ul.group-1 li, ul.group-2 li, ul.group-3 li {
          margin: 0.75em 0;
        }

        .skip-to-navigation a:visited {
          color: #000;
        }
        .skip-to-navigation a:hover {
          color: #fff;
        }
      }
    end
  end
end

module Iworkontheweb::Views

  def layout
    html do
      head do
        title(@page_title || "I work on the web.")
        link :rel => 'stylesheet', :type => 'text/css', :href => '/iworkontheweb.css', :media => 'screen'
      end
      body(:class => @body_class) do
        p(:class => "skip-to-navigation") { a "Skip to navigation", :href => "#navigation" }
        h1.header { a 'I work on the web.', :href => R(Home) }
        self << yield
        div :id => "navigation", :class => "navigation" do
          h2 "Most recent"
          ul do
            for person in @latest
              li { a person.name, :href => R(Show, person.to_param) }
            end
            _nav_links
          end
        end
        div(:class => "clear-both") { "" }
      end
    end
  end

  def home
    _person(@person) if @person
  end

  def index
    div.profiles do
      h2 "All #{@people.length} people:"
      @people.in_groups_of((@people.length.to_f / 3.0).ceil).each_with_index do |group, i|
        ul :class => "group-#{i+1}" do
          for person in group
            li { a person.name, :href => R(Show, person.to_param) } if person
          end
        end
      end
    end
  end
  
  def show
    _person(@person)
  end
  
  def not_found
    div.page { p "Page not found." }
  end

  # partials
  def _person(person)
    div :class => 'profile', :style => "width:#{person.image_width}px" do
      a :href => person.source_flickr_photo_url do
        img :src => person.image_source_url, :alt => person.name, :width => person.image_width.to_s, :height => person.image_height.to_s
      end
      h2 { a person.name, :href => R(Show, person.to_param) }
      div.copy do
        person.formatted_story +
        p { span.source { "Source: " + a(person.source_flickr_photo_url, :href => person.source_flickr_photo_url) } }
      end
    end    
  end

  def _nav_links
    li(:class => "view-all") { a "View all #{@person_count} people", :href => R(Index) }
    li(:class => "where-it-all-started") { a "Where it all started", :href => R(Show, "1-lisa-herrod") }
  end
end

def Iworkontheweb.create
  Camping::Models::Session.create_schema
  Iworkontheweb::Models.create_schema :assume => (Iworkontheweb::Models::Person.table_exists? ? 1.0 : 0.0)
  Iworkontheweb.create_fixtures unless Iworkontheweb::Models::Person.count > 0
end

def Iworkontheweb.create_fixtures
  story = <<STORY
  This is me, I work on the web.<br />
  <br />
  I live in Sydney and work as a User Experience Consultant. I spend *a lot* of time online for work and for fun.<br />
  <br />
  Some of my friends work on the web and some don't. For example, I have a friend who is a full-time mum, an artist, there's a script writer, a builder, a chef, some interpreters, teachers, a marine engineer, musicians, journalists and designers, plus some other non-web IT people too.<br />
  <br />
  I love working on the web and I truly believe it’s an amazing source of information, education, socialisation, freedom, creativity, solace, privacy, entertainment and so much more than I could ever express, because it's important to us all in so many ways. These are just some of the reasons I spend so much time online and participate in so many web events. <br />
  <br />
  I love learning new things, finding out how they work and understanding what people do in detail. Being involved in so many things gives me the opportunity to do that. <br />
  <br />
  Despite such an extraverted post, I am actually very reserved, which is sometimes, unfortunately, misinterpreted as aloof. I relate better to people in small groups and one on one situations with people I know, but I still love the energy that we create when we all get together. I feel incredibly lucky that I've been able to make so many wonderful friends and that it's enabled me to meet so many smart, fun, silly, generous, crazy, creative people online and off.<br />
  <br />
  I don’t belong to a clique and challenge anyone to say that I do. I love being involved in the web community and feel so fortunate for what I've experienced and learnt by being a part of it. <br />
  <br />
  I think it’s important to give something back to the community we enjoy so that it continues to grow and develop in positive ways. So if you’re reserved like me or too shy to join in or come along on your own, flickr me and we can go along together….<br />
  <br />
  This is who I am... <a href="http://flickr.com/photos/tags/iworkontheweb/">Who are you</a>?&nbsp;
STORY
  Iworkontheweb::Models::Person.create(:created_at => Time.now,
                                       :name => "Lisa Herrod",
                                       :story => story,
                                       :source_flickr_photo_url => "http://flickr.com/photos/lisaherrod/1273023044/",
                                       :image_source_url => "http://farm2.static.flickr.com/1269/1273023044_cac184a2e7.jpg",
                                       :image_width => "375",
                                       :image_height => "500")
  story = <<STORY
  This is me, I work on the web<br />
  <br />
  I live in beautiful Sydney (but still prefer Melbourne) and work for the mainstream media in the form of News Digital Media. I'm currently responsible for all front end development on NEWS.com.au, our flagship site<br />
  <br />
  Aside from that, I work with friends on little projects here and there. I also do some freelance when I can squeeze it in<br />
  <br />
  I'm deeply into our local web community. I go to every user group meeting and conference I can get to. Railscamp, Web Directions, WSG, SXSW etc. I've even run a few events<br />
  <br />
  I love the web community. There is something about the web that encourages people to share and help each other. At the events I go to, people are so passionate, so excited. They really love the web. They have a vision for it. Everybody's vision differs, but they're all interesting and they're all possible<br />
  <br />
  I see so much potential and so much excitement in the web and that's due to the people. I want to encourage that, however I can&nbsp;
STORY
  Iworkontheweb::Models::Person.create(:created_at => Time.now + 5.minutes,
                                       :name => "Lachlan Hardy",
                                       :story => story,
                                       :source_flickr_photo_url => "http://flickr.com/photos/lachlanhardy/1298077841/",
                                       :image_source_url => "http://farm2.static.flickr.com/1304/1298077841_c56d713f21.jpg",
                                       :image_width => "500",
                                       :image_height => "375")
end