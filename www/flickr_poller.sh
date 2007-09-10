#!/bin/sh
env CAMPING_ENV=production /usr/bin/ruby /var/www/iworkontheweb/app/flickr_poller.rb >> /tmp/flickr_poller.log
