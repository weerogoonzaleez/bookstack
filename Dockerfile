#Download base image ubuntu 16.04
FROM ubuntu:16.04
 
# Update Software repository
RUN apt-get update
 
# Install nginx, php-fpm and supervisord from ubuntu repository
RUN apt-get install -y nginx php7.0-fpm supervisor && \
    rm -rf /var/lib/apt/lists/*

#Define the ENV variable
ENV nginx_vhost /etc/nginx/sites-available/default
ENV php_conf /etc/php/7.0/fpm/php.ini
ENV nginx_conf /etc/nginx/nginx.conf
ENV supervisor_conf /etc/supervisor/supervisord.conf
ENV bookstackEnv /var/bookstack
ARG DEBIAN_FRONTEND=noninteractive

COPY after-run.sh /usr/after-run.sh
RUN chmod +x /usr/after-run.sh

RUN apt-get update

RUN apt-get -qq -y install mysql-client 
#RUN /usr/wait-for-it.sh

# Enable php-fpm on nginx virtualhost configuration
COPY default ${nginx_vhost}
COPY html/ /var/www/
RUN sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${php_conf} && \
    echo "\ndaemon off;" >> ${nginx_conf}
 
#Copy supervisor configuration
COPY supervisord.conf ${supervisor_conf}
 
RUN mkdir -p /run/php && \
    chown -R www-data:www-data /var/www/html && \
    chown -R www-data:www-data /run/php

VOLUME ["/var/www/html"]


RUN apt-get update
RUN apt-get install -y language-pack-en-base && locale-gen en_US.UTF-8
RUN export LANG=en_US.UTF-8
RUN export LC_ALL=en_US.UTF-8

RUN apt install -y software-properties-common 
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
RUN apt-get update

#Install bookstack dependencies
RUN apt install -qq -y curl
RUN apt install -qq -y fontconfig
RUN apt install -qq -y memcached
RUN apt install -qq -y netcat-openbsd
RUN apt install -qq -y php7.0-ctype
RUN apt install -qq -y php7.0-curl
RUN apt install -qq -y php7.0-dom
RUN apt install -qq -y php7.0-gd
RUN apt install -qq -y php7.0-ldap
RUN apt install -qq -y php7.0-mbstring
RUN apt install -qq -y php7.0-memcached
RUN apt install -qq -y php7.0-mysqlnd
RUN apt install -qq -y libapache2-mod-php7.0
RUN apt install -qq -y php7.0-mysql
RUN apt install -qq -y php7.0-phar
RUN apt install -qq -y php7.0-simplexml
RUN apt install -qq -y php7.0-tidy
RUN apt install -qq -y php7.0-tokenizer
RUN apt install -qq -y tar
RUN apt install -qq -y ttf-freefont 
RUN apt install -qq -y wkhtmltopdf
RUN curl -s \
	http://dl-cdn.alpinelinux.org/alpine/v3.7/community/x86_64/tidyhtml-libs-5.4.0-r0.apk | \
	tar xfz - -C / && \
 rm -f /usr/lib/libtidy.so.5.6.0



RUN echo "**** install  composer ****" && \
 cd /tmp && \
 curl -sS https://getcomposer.org/installer | php && \
 mv /tmp/composer.phar /usr/local/bin/composer

# Volume configuration


RUN apt install -qq -y git
RUN mkdir -p /var/bookstack
#
RUN git clone --branch v0.20.3  https://github.com/BookStackApp/BookStack.git /var/bookstack

COPY .env ${bookstackEnv}

VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

RUN chmod 755 -R /var/bookstack
RUN cd /var/bookstack && ls -lha 

WORKDIR /var/bookstack
RUN composer install 


#CMD bash -c "php artisan key:generate"
#CMD bash -c "php artisan migrate"
 

WORKDIR /
# Configure Services and Port
COPY start.sh /start.sh
CMD ["./start.sh"]
 
EXPOSE 80 443