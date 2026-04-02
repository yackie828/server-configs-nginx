# Linux Setup Guide for Nginx Server Configs

This guide provides comprehensive instructions for setting up and using the Nginx Server Configs on various Linux distributions.

## Quick Start - Launch Nginx

If Nginx is already installed and you just need to start it:

```bash
# Start Nginx
sudo systemctl start nginx

# Enable Nginx to start automatically on boot
sudo systemctl enable nginx

# Check if Nginx is running
sudo systemctl status nginx

# Test your Nginx installation
curl -I http://localhost
```

For detailed installation and configuration instructions, see the sections below.

## Table of Contents

- [Quick Start - Launch Nginx](#quick-start---launch-nginx)
- [Prerequisites](#prerequisites)
- [Installing Nginx](#installing-nginx)
  - [Ubuntu/Debian](#ubuntudebian)
  - [CentOS/RHEL/Rocky Linux](#centosrhelrocky-linux)
  - [Fedora](#fedora)
  - [Arch Linux](#arch-linux)
  - [openSUSE](#opensuse)
- [Deploying Server Configs](#deploying-server-configs)
- [Configuration](#configuration)
- [Permissions and Ownership](#permissions-and-ownership)
- [SELinux Considerations](#selinux-considerations)
- [Service Management](#service-management)
- [Testing and Validation](#testing-and-validation)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before installing Nginx and deploying these configurations:

- Root or sudo access to your Linux system
- Basic understanding of Linux command line
- Git installed (for cloning the repository)
- Text editor (vim, nano, or your preferred editor)

## Installing Nginx

### Ubuntu/Debian

```bash
# Update package index
sudo apt update

# Install Nginx
sudo apt install nginx

# Verify installation
nginx -v

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

### CentOS/RHEL/Rocky Linux

```bash
# Install EPEL repository (if not already installed)
sudo yum install epel-release

# Install Nginx
sudo yum install nginx

# Verify installation
nginx -v

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Configure firewall
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

### Fedora

```bash
# Install Nginx
sudo dnf install nginx

# Verify installation
nginx -v

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Configure firewall
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

### Arch Linux

```bash
# Install Nginx
sudo pacman -S nginx

# Verify installation
nginx -v

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

### openSUSE

```bash
# Install Nginx
sudo zypper install nginx

# Verify installation
nginx -v

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Configure firewall
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

## Deploying Server Configs

### Method 1: Direct Replacement (Recommended for new installations)

```bash
# Stop Nginx
sudo systemctl stop nginx

# Backup existing configuration
sudo mv /etc/nginx /etc/nginx-backup-$(date +%Y%m%d)

# Clone this repository
sudo git clone https://github.com/h5bp/server-configs-nginx.git /etc/nginx

# Change to nginx directory
cd /etc/nginx

# Set proper ownership
sudo chown -R root:root /etc/nginx

# Continue to Configuration section below
```

### Method 2: Reference and Selective Integration

```bash
# Clone repository to a working directory
git clone https://github.com/h5bp/server-configs-nginx.git ~/nginx-configs

# Copy desired components
sudo cp ~/nginx-configs/h5bp /etc/nginx/ -r
sudo cp ~/nginx-configs/mime.types /etc/nginx/

# Integrate into your existing nginx.conf
# (manually edit /etc/nginx/nginx.conf to include desired features)
```

## Configuration

After deploying the configs, you must customize them for your system:

### 1. Edit nginx.conf

```bash
sudo vim /etc/nginx/nginx.conf
```

**Important settings to verify/modify:**

- **user**: Change to match your system's web user
  - Ubuntu/Debian: `www-data`
  - CentOS/RHEL/Fedora: `nginx`
  - Other: Check with `ps aux | grep nginx`

- **error_log**: Verify path exists
  - Default: `/var/log/nginx/error.log`

- **pid**: Verify path is correct
  - Debian/Ubuntu: `/run/nginx.pid` or `/var/run/nginx.pid`
  - RHEL/CentOS: `/var/run/nginx.pid`

- **access_log**: Verify path exists
  - Default: `/var/log/nginx/access.log`

Example configuration snippet:

```nginx
# For Ubuntu/Debian
user www-data;
error_log /var/log/nginx/error.log warn;
pid /run/nginx.pid;

# For CentOS/RHEL/Fedora
user nginx;
error_log /var/log/nginx/error.log warn;
pid /run/nginx.pid;
```

### 2. Create custom.d directory (if not exists)

```bash
sudo mkdir -p /etc/nginx/custom.d
```

### 3. Set up your first site

```bash
cd /etc/nginx/conf.d

# Copy the template
sudo cp templates/example.com.conf yourdomain.com.conf

# Edit the configuration
sudo sed -i 's/example.com/yourdomain.com/g' yourdomain.com.conf

# Edit and customize further if needed
sudo vim yourdomain.com.conf
```

## Permissions and Ownership

Ensure proper permissions for security:

```bash
# Set ownership of config files
sudo chown -R root:root /etc/nginx

# Set permissions for config files (readable by all, writable by root)
sudo find /etc/nginx -type f -exec chmod 644 {} \;
sudo find /etc/nginx -type d -exec chmod 755 {} \;

# Set permissions for log directory
sudo chown -R www-data:www-data /var/log/nginx  # Ubuntu/Debian
# OR
sudo chown -R nginx:nginx /var/log/nginx        # CentOS/RHEL

# Set permissions for web root (adjust path as needed)
sudo chown -R www-data:www-data /var/www         # Ubuntu/Debian
# OR
sudo chown -R nginx:nginx /usr/share/nginx/html  # CentOS/RHEL
```

## SELinux Considerations

If you're using RHEL, CentOS, Fedora, or other distributions with SELinux:

### Check SELinux Status

```bash
sestatus
```

### Allow Nginx to Network Connect (if needed)

```bash
sudo setsebool -P httpd_can_network_connect 1
```

### Set Correct SELinux Context for Web Content

```bash
# For custom web root
sudo semanage fcontext -a -t httpd_sys_content_t "/var/www(/.*)?"
sudo restorecon -Rv /var/www

# For Nginx config files (should be correct by default)
sudo restorecon -Rv /etc/nginx
```

### Troubleshooting SELinux Issues

If you encounter permission errors, check SELinux logs:

```bash
sudo ausearch -m avc -ts recent
```

Or temporarily set SELinux to permissive mode for testing:

```bash
sudo setenforce 0  # Permissive mode
# Test your configuration
sudo setenforce 1  # Re-enable enforcing mode
```

**Note**: Never leave SELinux in permissive mode in production.

## Service Management

### Using systemd (most modern Linux distributions)

```bash
# Start Nginx
sudo systemctl start nginx

# Stop Nginx
sudo systemctl stop nginx

# Restart Nginx
sudo systemctl restart nginx

# Reload configuration without dropping connections
sudo systemctl reload nginx

# Enable Nginx to start on boot
sudo systemctl enable nginx

# Disable auto-start on boot
sudo systemctl disable nginx

# Check status
sudo systemctl status nginx

# View logs
sudo journalctl -u nginx -f
```

### Configuration Testing

Always test configuration before reloading:

```bash
# Test configuration syntax
sudo nginx -t

# Test with specific config file
sudo nginx -t -c /etc/nginx/nginx.conf

# If test passes, reload
sudo systemctl reload nginx
```

## Testing and Validation

### 1. Test Nginx is Running

```bash
# Check if Nginx is listening on port 80
sudo ss -tlnp | grep :80

# Or using netstat
sudo netstat -tlnp | grep :80

# Test HTTP response
curl -I http://localhost
```

### 2. Test Configuration Files

```bash
# Validate nginx.conf
sudo nginx -t

# Check for syntax errors
sudo nginx -T | less
```

### 3. Check Logs

```bash
# Error log
sudo tail -f /var/log/nginx/error.log

# Access log
sudo tail -f /var/log/nginx/access.log
```

## Troubleshooting

### Nginx won't start

1. **Check configuration syntax:**
   ```bash
   sudo nginx -t
   ```

2. **Check if port 80/443 is already in use:**
   ```bash
   sudo ss -tlnp | grep -E ':(80|443)'
   ```

3. **Check SELinux (RHEL/CentOS/Fedora):**
   ```bash
   sudo ausearch -m avc -ts recent
   ```

4. **Check logs:**
   ```bash
   sudo journalctl -u nginx -n 50
   sudo tail -n 50 /var/log/nginx/error.log
   ```

### Permission Denied Errors

1. **Check file ownership:**
   ```bash
   ls -l /etc/nginx/
   ls -l /var/log/nginx/
   ```

2. **Verify the user in nginx.conf matches system:**
   ```bash
   grep "^user" /etc/nginx/nginx.conf
   id www-data  # or id nginx
   ```

3. **Check SELinux context (RHEL/CentOS/Fedora):**
   ```bash
   ls -Z /etc/nginx/
   ```

### 403 Forbidden Errors

1. **Check web root permissions:**
   ```bash
   ls -la /var/www  # or your web root
   ```

2. **Verify index files exist:**
   ```bash
   ls -la /var/www/html/index.html  # or your document root
   ```

3. **Check Nginx error logs:**
   ```bash
   sudo tail -f /var/log/nginx/error.log
   ```

### Configuration Changes Not Taking Effect

1. **Test configuration first:**
   ```bash
   sudo nginx -t
   ```

2. **Reload (don't restart):**
   ```bash
   sudo systemctl reload nginx
   ```

3. **If reload doesn't work, restart:**
   ```bash
   sudo systemctl restart nginx
   ```

### Port Already in Use

1. **Find what's using the port:**
   ```bash
   sudo ss -tlnp | grep :80
   ```

2. **Stop the conflicting service:**
   ```bash
   sudo systemctl stop apache2  # if Apache is running
   ```

## Additional Resources

- [Nginx Official Documentation](https://nginx.org/en/docs/)
- [Nginx Beginners Guide](https://nginx.org/en/docs/beginners_guide.html)
- [Main README](README.md)
- [Contributing Guidelines](.github/CONTRIBUTING.md)

## Support

For issues specific to these configurations, please check:
- [Issue Tracker](https://github.com/h5bp/server-configs-nginx/issues)
- [Stack Overflow - Nginx Tag](https://stackoverflow.com/questions/tagged/nginx)

For Linux-specific system issues:
- Your distribution's documentation
- Distribution-specific forums and communities
