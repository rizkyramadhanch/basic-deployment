#!/bin/sh
ssh cilsy@192.168.0.2 "cd /home/cilsy/public_html/social-media && git checkout master && git pull origin master exit"
ssh cilsy@192.168.0.3 "cd /home/cilsy/public_html/social-media && git checkout master && git pull origin master"