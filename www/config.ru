require 'rubygems'
require 'rack'

gem 'activerecord', '=2.1.2'
require 'active_record'

gem 'camping', '~>1'
require 'camping'

require File.dirname(__FILE__) + '/iworkontheweb'

ENV["CAMPING_ENV"] = "production"
Iworkontheweb.establish_db_connection

run Rack::Adapter::Camping.new(Iworkontheweb)
