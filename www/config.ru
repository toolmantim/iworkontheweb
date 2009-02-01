require 'rubygems'
require 'rack'

gem 'camping', '~>1'
require 'camping'

require File.dirname(__FILE__) + '/iworkontheweb'

run Rack::Adapter::Camping.new(Iworkontheweb)
