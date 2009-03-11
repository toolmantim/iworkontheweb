require 'rubygems'
require 'rack'

gem 'camping'
require 'camping'

require File.dirname(__FILE__) + '/iworkontheweb'

ENV["CAMPING_ENV"] = "production"
Iworkontheweb.establish_db_connection

run Rack::Adapter::Camping.new(Iworkontheweb)
