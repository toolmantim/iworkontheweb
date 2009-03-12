#!/bin/sh
env IWOTW_ENV=production /usr/bin/ruby /var/www/iworkontheweb/app/flickr_poller.rb >> /tmp/flickr_poller.log
