FROM php:8.0-apache

#Install git and MySQL extensions for PHP

RUN apt-get update && apt-get install -y git libpng-dev zlib1g-dev
RUN apt-get install -y libicu-dev \
  && docker-php-ext-configure intl \
  && docker-php-ext-install intl
RUN apt-get install -y libc-client-dev libkrb5-dev &&     rm -r /var/lib/apt/lists/* &&     docker-php-ext-configure imap --with-kerberos --with-imap-ssl &&     docker-php-ext-install imap 
RUN pecl channel-update pecl.php.net
RUN docker-php-ext-install gd
RUN pecl install apcu
RUN docker-php-ext-enable apcu opcache
RUN docker-php-ext-install pdo pdo_mysql mysqli 
RUN a2enmod rewrite

# Copy the source code and change permissions to the config file
COPY src /var/www/html/
RUN chmod 666 /var/www/html/include/ost-config.php
EXPOSE 80/tcp
EXPOSE 443/tcp

# Setup Official Plugins
RUN git clone -b develop https://github.com/osTicket/osTicket-plugins /usr/src/plugins
RUN set -x && \    cd /usr/src/plugins && \
  php make.php hydrate && \
  for plugin in $(find * -maxdepth 0 -type d ! -path doc ! -path lib); do cp -r ${plugin} /var/www/html/include/plugins; done; \
  cd / && \
  \
  # Setup Community Plugins
  ## Archiver
  git clone https://github.com/clonemeagain/osticket-plugin-archiver /var/www/html/include/plugins/archiver && \
  ## Attachment Preview
  git clone https://github.com/clonemeagain/attachment_preview /var/www/html/include/plugins/attachment-preview && \
  ## Auto Closer
  git clone https://github.com/clonemeagain/plugin-autocloser /var/www/html/include/plugins/auto-closer && \
  ## Fetch Note
  git clone https://github.com/bkonetzny/osticket-fetch-note /var/www/html/include/plugins/fetch-note && \
  ## Field Radio Buttons
  git clone https://github.com/Micke1101/OSTicket-plugin-field-radiobuttons /var/www/html/include/plugins/field-radiobuttons && \
  ## Mentioner
  git clone https://github.com/clonemeagain/osticket-plugin-mentioner /var/www/html/include/plugins/mentioner && \
  ## Multi LDAP Auth
  git clone https://github.com/philbertphotos/osticket-multildap-auth /var/www/html/include/plugins/multi-ldap && \
  mv /var/www/html/include/plugins/multi-ldap/multi-ldap/* /var/www/html/include/plugins/multi-ldap/ && \
  rm -rf /var/www/html/include/plugins/multi-ldap/multi-ldap && \
  ## Prevent Autoscroll
  git clone https://github.com/clonemeagain/osticket-plugin-preventautoscroll /var/www/html/include/plugins/prevent-autoscroll && \
  ## Rewriter
  git clone https://github.com/clonemeagain/plugin-fwd-rewriter /var/www/html/include/plugins/rewriter && \
  ## Slack
  git clone https://github.com/clonemeagain/osticket-slack /var/www/html/include/plugins/slack && \
  ## Teams (Microsoft)
  git clone https://github.com/ipavlovi/osTicket-Microsoft-Teams-plugin /var/www/html/include/plugins/teams && \
  \
  ## Cleanup
  apt-get clean && \
  rm -rf /usr/src/*