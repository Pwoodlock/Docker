#!/bin/bash
set -e

# Check if DATA_PATH is set, if not set default
DATA_PATH=${DATA_PATH:-/var/www/html}

# Add logging with proper permissions
mkdir -p /var/log
touch /var/log/entrypoint.log
chown www-data:www-data /var/log/entrypoint.log
exec 1> >(tee -a "/var/log/entrypoint.log") 2>&1

echo "[$(date)] Starting custom entrypoint script"
echo "[$(date)] Using DATA_PATH: ${DATA_PATH}"

# Wait for the volume to be mounted
while [ ! -d "${DATA_PATH}" ]; do
    echo "[$(date)] Waiting for ${DATA_PATH} to be mounted..."
    sleep 1
done
echo "[$(date)] Volume mounted successfully"

# Rest of your script remains the same...

# Update configuration.php if it exists
if [ -f "${DATA_PATH}/configuration.php" ]; then
    echo "[$(date)] Updating configuration.php"
    sed -i \
        -e "s/public \$user = '.*'/public \$user = '${JOOMLA_DB_USER}'/" \
        -e "s/public \$password = '.*'/public \$password = '${JOOMLA_DB_PASSWORD}'/" \
        -e "s/public \$db = '.*'/public \$db = '${JOOMLA_DB_NAME}'/" \
        -e "s/public \$upload_maxsize = '.*'/public \$upload_maxsize = '100M'/" \
        -e "s/public \$smtppass = '.*'/public \$smtppass = '${SMTP_PASSWORD}'/" \
        -e "s/public \$gzip = .*$/public \$gzip = false;/" \
        "${DATA_PATH}/configuration.php"
    echo "[$(date)] Configuration updated successfully"
fi

echo "[$(date)] Executing: $@"
exec "$@"  # Fixed the exec line by removing asterisks