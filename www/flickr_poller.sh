#!/bin/sh
env CAMPING_ENV=production /usr/bin/ruby flickr_poller.rb >> /tmp/flickr_poller.log
