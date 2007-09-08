#!/usr/bin/env ruby

require 'rubygems'
require 'camping'
require 'camping/session'

Camping.goes :Iworkontheweb

module Iworkontheweb
  include Camping::Session
end

module Iworkontheweb::Models
  class Person < Base
    def self.latest
      find(:all, :order => 'created_at DESC', :limit => 15)
    end
    def self.all
      find(:all, :order => 'created_at ASC')
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
end

module Iworkontheweb::Controllers
  class Home < R '/'
    def get
      @body_class = "home"
      @person_count = Person.count
      @latest = Person.latest
      @person = @latest.last
      render :home
    end
  end
  class Show < R '/profiles/(\d+)-[a-z-]*'
    def get(id)
      @body_class = "show-profile"
      @person_count = Person.count
      @latest = Person.latest
      @profile = Person.find(id)
      @page_title = @profile.name
      render :show
    rescue ActiveRecord::RecordNotFound
      @headers["Status"] = "404 Not Found"
      @page_title = "Page not found."
      render :not_found
    end
  end
  class Index < R '/profiles'
    def get
      @body_class = "archive"
      @person_count = Person.count
      @latest = Person.latest
      @people = Person.all
      @page_title = %(All #{@person_count} "I work on the web" profiles)
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

        .profile h2 {
          font-size: 24px;
          text-align: right;
          margin-top: 10px;
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

        p {
          margin: 1em 0;
        }

        a {
          color: #000;
        }

        a:hover {
          text-decoration: none;
          background-color: #000;
          color: #fff;
        }
        a:visited {
          color: #999;
        }
        .skip-to-navigation a {
          color: #000;
        }

        .home .navigation .view-all,
        .all-profiles .navigation .where-it-all-started {
          margin-top: 10px;  
        }

        .all-profiles .profiles {
          width: 550px;
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

        h1 a, h1 a:visited, h1 a:hover {
          background-color: #fff;
          color: #000;
          text-decoration: none;
        }
        h1 a:hover {
          text-decoration: underline;
        }

        .skip-to-navigation a:visited, .view-all a:visited, .most-recent a:visited {
          color: #000;
        }
        .skip-to-navigation a:hover, .view-all a:hover, .most-recent a:hover {
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
        h1.header { a 'I work on the web.', :href => R(Home) }
        div.content do
          self << yield
        end
      end
    end
  end

  def home
    _person(@latest_person)
  end

  def index
    # if @posts.empty?
    #   p 'No posts found.'
    #   p { a 'Add', :href => R(Add) }
    # else
    #   for post in @posts
    #     _post(post)
    #   end
    # end
  end


  def show
    
  end
  
  def not_found
    p { "Page not found. Check out " + a("all #{@person_count} people", :href => R(Index)) }
  end

  # partials
  def _person(person)
    
  end
end

def Iworkontheweb.create
  Camping::Models::Session.create_schema
  Iworkontheweb::Models.create_schema :assume => (Iworkontheweb::Models::Person.table_exists? ? 1.0 : 0.0)
end