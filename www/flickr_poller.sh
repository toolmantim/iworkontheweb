#!/bin/sh
env IWOTW_ENV=production /usr/bin/ruby /var/www/iworkontheweb/app/flickr_poller.rb > /dev/null 2>&1
