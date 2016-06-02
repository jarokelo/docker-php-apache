Important things:

* Logging is done to a remote syslog server, hostname `logger`.
* Email is relayed to remote smtp server, hostname `mailer`.
* Apache runs as www-data.
* ADD a crontab to /etc/crontab if you want cron jobs. Run cron jobs as www-data.
* COPY the app to /var/www
* ADD a site configuration to /etc/apache2/sites-enabled/
