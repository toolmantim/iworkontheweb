puts "merb init called"
require 'active_record'
ActiveRecord::Base.verification_timeout = 14400
ActiveRecord::Base.logger = MERB_LOGGER

require DIST_ROOT+"/app/controllers/application.rb"
Dir[DIST_ROOT+"/app/controllers/*.rb"].each{ |m| require m } 
Dir[DIST_ROOT+"/app/helpers/*.rb"].each    { |m| require m } 
Dir[DIST_ROOT+"/app/models/*.rb"].each     { |m| require m } 
Dir[DIST_ROOT+"/app/mailers/*.rb"].each    { |m| require m }
Dir[DIST_ROOT+"/lib/*/lib/*.rb"].each      { |m| require m }
Dir[DIST_ROOT+"/lib/*/bin/*.rb"].each      { |m| require m }
Dir[DIST_ROOT+"/plugins/*/init.rb"].each   { |m| require m }

#Get Database Config
puts "Connecting to database..."
conn_options = YAML::load(Erubis::Eruby.new(IO.read("#{DIST_ROOT}/conf/database.yml")).result)
ActiveRecord::Base.establish_connection conn_options["#{MERB_ENV}"] 

#Get Environment File
require "#{DIST_ROOT}/conf/environments/#{MERB_ENV}"

# add your own ruby code here for app specific stuff. This file gets loaded
# after the framework is loaded.
