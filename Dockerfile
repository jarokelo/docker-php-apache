FROM debian:jessie
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    apache2 apache2-mpm-prefork php5-cli libapache2-mod-php5 \
    php5-gd php5-curl php5-intl php5-mysql php5-pgsql \
    php5-sqlite php5-xmlrpc php5-xsl php5-json \
    php5-memcache php5-mcrypt \
    locales \
    cron \
    rsyslog \
    supervisor \
    ssmtp \
    && \
    rm -rf /var/lib/apt/lists/*

ADD locale.gen /etc/locale.gen
RUN locale-gen
ENV LC_CTYPE en_US.UTF-8

RUN a2enmod rewrite
RUN a2dismod mpm_event && a2enmod mpm_prefork
ADD php.ini /etc/php5/apache2/php.ini
ADD envvars /etc/apache2/envvars
ADD default.conf /etc/apache2/sites-enabled/000-default.conf

RUN rm -rf /var/www/html && mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

# add supervisor config
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# add syslog config
ADD rsyslog.conf /etc/rsyslog.conf
ADD apache_syslog /usr/local/bin/apache_syslog

ADD ssmtp.conf /etc/ssmtp/ssmtp.conf

WORKDIR /var/www/html

EXPOSE 80
CMD ["/usr/bin/supervisord"]
