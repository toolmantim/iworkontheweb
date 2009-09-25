require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'

gem 'activerecord', '= 2.1.2'
require 'activerecord'

ENV['IWOTW_ENV'] ||= Sinatra::Application.environment.to_s
require 'models'

before do
  @person_count = Person.count
  @latest = Person.recent
end

helpers do
  def person(person)
    haml :_person, :layout => false, :locals => {:person => person}
  end
  def person_path(person)
    "/profiles/#{person.to_param}"
  end
end

get '/' do
  @person = Person.latest
  haml :home
end

get '/profiles' do
  @people = Person.all
  @page_title = %(All #{@person_count} I work on the web profiles)
  haml :profiles
end

get '/profiles/:id' do
  @person = Person.find_without_deleted(params[:id]) || raise(Sinatra::NotFound)
  @page_title = "#{@person.name} - I work on the web."
  haml :profile
end

get '/profiles.atom' do
  content_type "application/atom+xml"
  @people = Person.recent
  haml :profiles_atom
end

get '/add-your-profile' do
  @page_title = "Add your profile to iworkontheweb.com"
  haml :add_your_profile
end

get '/iworkontheweb.css' do
  content_type "text/css"
  sass :screen
end

get '/about' do
  @page_title = "About iworkontheweb.com"
  haml :about      
end