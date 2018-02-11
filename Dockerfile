FROM debian:stable

RUN apt-get update
RUN apt-get install -y --no-install-recommends nginx
RUN mkdir /var/run/php/
RUN chown www-data:www-data /var/run/php/
RUN apt-get install -y --no-install-recommends libterm-readline-gnu-perl php-fpm php-intl php-mbstring php-codesniffer php-xml curl git unzip curl
ADD nginx.conf /etc/nginx/sites-enabled/default
ADD www.conf /etc/php/7.0/fpm/pool.d/www.conf
RUN mkdir /var/vendor/ && chown www-data:www-data /var/vendor
RUN curl -k https://getcomposer.org/installer > /tmp/composer-setup
RUN php /tmp/composer-setup
RUN mv composer.phar /usr/local/bin/composer
RUN chown -R www-data:www-data /var/www/
RUN cd /var/www ; su --shell /bin/bash www-data -c "/usr/local/bin/composer create-project --no-interaction --prefer-dist cakephp/app /var/www/html/cake"
RUN cd /var/www/html/cake ; su --shell /bin/bash www-data -c "/usr/local/bin/composer require --no-interaction league/monga"
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log
EXPOSE 80
ADD start_service /usr/local/bin/start_service
CMD sh /usr/local/bin/start_service
