#!/bin/sh

apt-get update -y
##check available package
apt list |grep "package_name"


apt-get install git nginx mysql-server php-fpm php-mysqli -y

### setup application
mkdir public_html
cd public_html
git clone git@github.com:rizkyramadhanch/sosial-media.git
cd social-media
################################ manipulate config.php
#sed config.php


#start service
systemctl start nginx && systemctl start mysqld && systemctl start php-fpm


#set initial root password mysql
#enter your passowrd
mysql_secure_installation

#create db, user, and grant permission
mysql -u root -h localhost -p -e
"- CREATE DATABASE SOCIAL_MEDIA
 - create user cilsy
 - grant permission cilsy to db SOCIAL_MEDIA
 - add flush priviledge"

#create virtualhost cilsy.id
cat > /etc/nginx/conf.d/socmed.conf << EOF
server {                                                                                                                                                                                                                                      
   server_name cilsy.id;                                                                                                                                                                                                                      
   root /home/cilsy/public_html/social-media;                                                                                                                                                                                                
                                                                                                                                                                                                                                              
   access_log  /var/log/nginx/api-ws.access.log ;                                                                                                                                                                                             
   error_log /var/log/nginx/api-ws.error.log error;                                                                                                                                                                                           
                                                                                                                                                                                                                                              
   index index.php index.html index.htm;                                                                                                                                                                                                      
                                                                                                                                                                                                                                              
   location ~* \.(?:ico|css|js|xml)$ {                                                                                                                                                                                                        
            expires max;                                                                                                                                                                                                                      
            add_header Pragma no-cache;                                                                                                                                                                                                       
            add_header Cache-Control "public, no-cache";                                                                                                                                                                                      
    #       add_header Cache-Control "public, max-age=900";                                                                                                                                                                                   
        }                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                              
   location / {                                                                                                                                                                                                                               
        try_files   $uri $uri/ /index.php?$query_string;                                                                                                                                                                                      
    }                                                                                                                                                                                                                                         
                                                                                                                                                                                                                                              
    # Remove trailing slash to please routing system.                                                                                                                                                                                         
    if (!-d $request_filename) {                                                                                                                                                                                                              
        rewrite     ^/(.+)/$ /$1 permanent;                                                                                                                                                                                                   
    }                                                                                                                                                                                                                                         
                                                                                                                                                                                                                                              
#   location ~ \.php$ {                                                                                                                                                                                                                       
#        fastcgi_split_path_info ^(.+\.php)(/.+)$;                                                                                                                                                                                            
#        fastcgi_pass php-fpm-sock;                                                                                                                                                                                                           
#       fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;                                                                                                                                                                   
#       fastcgi_read_timeout 1800;
#       fastcgi_connect_timeout 1800; 
#       fastcgi_index index.php;
#       include fastcgi_params;       
#   }

#    # PHP-FPM Configuration Nginx                             
#        location ~ \.php$ {
#                try_files $uri =404;
#                fastcgi_split_path_info ^(.+\.php)(/.+)$;
#                fastcgi_pass unix:/run/php-fpm/php-fpm.sock;
#                fastcgi_index index.php;
#                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
#                include fastcgi_params;
#        }                                 
                                              
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;                      
        fastcgi_pass 127.0.0.1:9000;
        #fastcgi_pass unix:/var/run/php7.4-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_buffers 64 64k;              
        fastcgi_buffer_size 64k;
        fastcgi_read_timeout 300;                
    }                                              

   location ~ /\.ht {                   
            deny all;
    }                                 

    listen 443 ssl; # managed by Certbot
    #ssl_certificate /etc/letsencrypt/live/cilsy.app/fullchain.pem; # managed by Certbot
    #ssl_certificate_key /etc/letsencrypt/live/cilsy.app/privkey.pem; # managed by Certbot
    #include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    #ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
    ssl_certificate /home/cilsy/certificate/cilsy.app.crt;
    ssl_certificate_key /home/cilsy/certificate/cilsy.app.key;

}
server {
    if ($host = cilsy.app) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

                                                                                                                                                                                                                                      
   listen  80;                                                                                                                                                                                                                                
   server_name cilsy.app;
    return 404; # managed by Certbot


}
EOF

#check config
nginx -t
systemctl restart nginx