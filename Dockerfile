# Use an official PHP image with Apache
FROM php:7.4-apache

# Install necessary packages and extensions
RUN apt-get update && apt-get install -y \
    mariadb-client \
    zlib1g-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libldap2-dev \
    libsnmp-dev \
    snmp \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql mysqli ldap bcmath snmp pcntl \
    && a2enmod rewrite \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache mod_rewrite for URL rewriting
RUN a2enmod rewrite

RUN mkdir /var/www/html/doc

# Download and extract RackTables directly into /var/www/html
RUN curl -L https://github.com/RackTables/racktables/archive/refs/heads/maintenance-0.21.x.tar.gz | tar xz \
    && mv racktables-maintenance-0.21.x/* /var/www/html/doc

RUN rm -dr racktables-maintenance-0.21.x
RUN mv /var/www/html/doc/wwwroot/* /var/www/html/

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Allowing writing and access for app
RUN touch '/var/www/html/inc/secret.php'; chmod a=rw '/var/www/html/inc/secret.php'

# Set working directory
WORKDIR /var/www/html

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
