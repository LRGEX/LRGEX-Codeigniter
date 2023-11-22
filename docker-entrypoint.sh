#!/bin/bash
cat << "EOF"
██╗     ██████╗  ██████╗ ███████╗██╗  ██╗
██║     ██╔══██╗██╔════╝ ██╔════╝╚██╗██╔╝
██║     ██████╔╝██║  ███╗█████╗   ╚███╔╝ 
██║     ██╔══██╗██║   ██║██╔══╝   ██╔██╗ 
███████╗██║  ██║╚██████╔╝███████╗██╔╝ ██╗
╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ 
┌─┐┌─┐┌┬┐┌─┐╦╔═╗╔╗╔╦╔╦╗╔═╗╦═╗
│  │ │ ││├┤ ║║ ╦║║║║ ║ ║╣ ╠╦╝
└─┘└─┘─┴┘└─┘╩╚═╝╝╚╝╩ ╩ ╚═╝╩╚═  v4.3.3                                
EOF


# Path to the backup directory
BACKUP_DIR="/var/www/html_backup"

# Path to the mounted directory
MOUNTED_DIR="/var/www/html"
lrgex_flag=$(grep -c "started" /opt/ci/flags)
codeigniter_flag=$(grep -c "defined('BASE')" /var/www/html/app/Config/Constants.php)



# Check if the mounted directory is empty
if [ -z "$(ls -A $MOUNTED_DIR)" ]; then
    echo ""
    echo "Mounted directory is empty. Restoring content from backup..."
    echo ""
    cp -a $BACKUP_DIR/. $MOUNTED_DIR/
    echo ""
    echo "Done!"
    sleep 2
fi

if [ $lrgex_flag -eq 0 ];then
    echo ""
    echo "Configuring Permissions..."
    echo ""
    # Change ownership to www-data and set appropriate permissions
    chown -R www-data:www-data $MOUNTED_DIR
    chmod -R 755 $MOUNTED_DIR
    touch /opt/ci/flags
    echo "started" >> /opt/ci/flags
    echo ""
    echo "Done!"
    sleep 2
fi

if [ $codeigniter_flag -eq 0 ];then
    echo ""
    echo "Configuring CodeIgniter Base url..."
    echo ""
    # Set the base URL in the CodeIgniter configuration file and the Constants file
    sed -i 's/public string $baseURL = .*/public $baseURL = BASE;/' /var/www/html/app/Config/App.php
    echo "\$protocol = isset(\$_SERVER['HTTPS']) && \$_SERVER['HTTPS'] != 'off' ? 'https://' . \$_SERVER['HTTP_HOST'] : 'http://' . \$_SERVER['HTTP_HOST'];" >> /var/www/html/app/Config/Constants.php
    echo " defined('BASE') || define('BASE', \$protocol);" >> /var/www/html/app/Config/Constants.php
    echo ""
    echo "Done!"
    sleep 2
fi

echo ""
echo "Starting Apache..."
echo ""

# Start Apache in the foreground
exec apache2-foreground

