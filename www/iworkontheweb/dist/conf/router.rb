# Merb::RouteMatcher is the request routing mapper for the merb framework.
# You can define placeholder parts of the url with the :symbol notation. For
# example:
#
#   r.add '/admin/:email/users/:id', :controller => 'admin_users', :action => 'foo'
#
# will match against a request to /admin/me@gmail.com/users/456. It will then
# use the class AdminUsers as your merb controller and call the 'foo' method
# on it. The 'foo' method will be able to access the :email and :id values via
# the 'params' hash, e.g. 'params[:email]' will return 'me@gmail.com'.

puts "Compiling routes.."
Merb::Router.prepare do |r|
  # restfull routes
  # r.resources :posts

  # default route, usually you don't want to change this
  r.default_routes
  
  # change this for your home page to be avaiable at /
  r.add '/', :controller => 'profiles', :action =>'home'
  r.add '/people', :controller => 'profiles', :action =>'index'
  r.add '/people/:id', :controller => 'profiles', :action =>'show'
end
