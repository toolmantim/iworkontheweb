require 'iworkontheweb'

set :run, false
set :environment, :production
set :raise_errors, false

ENV['IWOTW_ENV'] ||= Sinatra::Application.environment.to_s

run Sinatra::Application
