FROM wordpress:6.7-apache

# Install PostgreSQL client and PHP PostgreSQL extensions
RUN apt-get update && \
    apt-get install -y \
        libpq-dev \
        postgresql-client \
        unzip \
        wget && \
    docker-php-ext-install pdo_pgsql pgsql && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and install PG4WP plugin
RUN cd /tmp && \
    wget https://downloads.wordpress.org/plugin/pg4wp.1.4.3.zip && \
    unzip pg4wp.1.4.3.zip && \
    mkdir -p /usr/src/wordpress/wp-content/plugins && \
    cp -r pg4wp /usr/src/wordpress/wp-content/plugins/ && \
    cp pg4wp/db.php /usr/src/wordpress/wp-content/ && \
    rm -rf /tmp/pg4wp*

# Ensure proper permissions
RUN chown -R www-data:www-data /usr/src/wordpress/wp-content
