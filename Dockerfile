FROM gitlab-registry.mito.hu/base-images/debian:jessie

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    && wget -qO - https://www.dotdeb.org/dotdeb.gpg | apt-key add - \
    && apt-get purge -y --auto-remove wget \
    && \
    rm -rf /var/lib/apt/lists/*

RUN echo "deb http://packages.dotdeb.org jessie all" | tee -a /etc/apt/sources.list
RUN echo "deb-src http://packages.dotdeb.org jessie all" | tee -a /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    apache2 apache2-mpm-prefork php7.0-cli libapache2-mod-php7.0 \
    php7.0-gd php7.0-curl php7.0-intl php7.0-mysql php7.0-pgsql \
    php7.0-sqlite php7.0-xmlrpc php7.0-xsl php7.0-json \
    php7.0-memcache php7.0-mcrypt \
    rsyslog \
    python \
    python-setuptools \
    python-pkg-resources \
    ssmtp \
    && easy_install supervisor \
    && apt-get purge -y --auto-remove python-setuptools \
    && \
    rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite
RUN a2dismod mpm_event && a2enmod mpm_prefork
#ADD php.ini /etc/php5/apache2/php.ini
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
