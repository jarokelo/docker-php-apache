FROM jarokelo/debian:jessie

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-transport-https lsb-release ca-certificates \
    wget \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && apt-get purge -y --auto-remove wget \
    && \
    rm -rf /var/lib/apt/lists/*

RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
RUN echo "deb-src https://packages.sury.org/php/ $(lsb_release -sc) main" >> /etc/apt/sources.list.d/php.list

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    apache2 apache2-mpm-prefork php7.2-cli libapache2-mod-php7.2 \
    php7.2-gd php7.2-curl php7.2-intl php7.2-mysql php7.2-pgsql \
    php7.2-sqlite3 php7.2-xmlrpc php7.2-xsl php7.2-json \
    php7.2-memcache php7.2-imap \
    php7.2-mbstring \
    php7.2-zip \
    php7.2-soap \
    php7.2-dev php-pear libmcrypt-dev make \
    rsyslog \
    python \
    python-setuptools \
    python-pkg-resources \
    ssmtp \
    && easy_install supervisor \
    && apt-get purge -y --auto-remove python-setuptools \
    && pecl install mcrypt-snapshot \
    && \
    rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite
RUN a2dismod mpm_event && a2enmod mpm_prefork
ADD php.ini /etc/php/7.2/apache2/php.ini
ADD php_apache.ini /etc/php/7.2/apache2/conf.d/php_apache.ini
ADD php.ini /etc/php/7.2/cli/php.ini
ADD envvars /etc/apache2/envvars
ADD other-vhosts-access-log.conf /etc/apache2/conf-available/other-vhosts-access-log.conf
#ADD default.conf /etc/apache2/sites-enabled/000-default.conf

# download and install go-cron
ENV GO_CRON 0.2.1
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    && \
    curl -SL "https://github.com/nkovacs/go-cron/releases/download/$GO_CRON/go-cron-linux-amd64" -o /usr/local/bin/go-cron \
    && chmod a+x /usr/local/bin/go-cron \
    && apt-get purge -y --auto-remove curl \
    && rm -rf /var/lib/apt/lists/*

RUN rm -rf /var/www/html && mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

ENV CRON_WORKDIR="/var/www/html"

ADD supervisor-watcher /usr/local/bin/supervisor-watcher
ADD sigproxy /usr/local/bin/sigproxy
ADD apache2cleanpid /usr/local/bin/apache2cleanpid

# add supervisor config
ADD supervisord.conf /etc/supervisor/supervisord.conf
ADD supervisor/* /etc/supervisor/conf.d/
# create log directory
RUN mkdir -p /var/log/supervisor

# add syslog config
ADD rsyslog.conf /etc/rsyslog.conf
ADD apache_syslog /usr/local/bin/apache_syslog

ADD ssmtp.conf /etc/ssmtp/ssmtp.conf

WORKDIR /var/www/html

EXPOSE 80
CMD ["/usr/local/bin/supervisord"]
