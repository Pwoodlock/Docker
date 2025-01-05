#!/bin/bash
set -e

# Wait for the volume to be mounted
while [ ! -d "${DATA_PATH}" ]; do
    sleep 1
done

# Update configuration.php if it exists
if [ -f "${DATA_PATH}/configuration.php" ]; then
    sed -i \
        -e "s/public \$user = '.*'/public \$user = getenv('JOOMLA_DB_USER')/" \
        -e "s/public \$password = '.*'/public \$password = getenv('JOOMLA_DB_PASSWORD')/" \
        -e "s/public \$db = '.*'/public \$db = getenv('JOOMLA_DB_NAME')/" \
        -e "s/public \$upload_maxsize = '.*'/public \$upload_maxsize = '100M'/" \
        -e "s/public \$smtppass = '.*'/public \$smtppass = getenv('SMTP_PASSWORD')/" \
        -e "s/public \$gzip = .*$/public \$gzip = false;/" \
        "${DATA_PATH}/configuration.php"

    # Add upload_maxsize if it doesn't exist
    if ! grep -q "public \$upload_maxsize" "${DATA_PATH}/configuration.php"; then
        sed -i '/class JConfig {/a \    public $upload_maxsize = '\''100M'\'';' "${DATA_PATH}/configuration.php"
    fi
fi

# Execute the original entrypoint
exec "$@"