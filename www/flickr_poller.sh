#!/bin/sh
env IWOTW_ENV=production /opt/ruby-enterprise/bin/ruby /var/www/iworkontheweb/app/current/www/flickr_poller.rb > /dev/null 2>&1
