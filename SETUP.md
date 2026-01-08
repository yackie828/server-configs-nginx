# Node.js Application with Nginx Reverse Proxy

This setup provides a complete configuration for running a Node.js Express application behind an Nginx reverse proxy.

## Components

1. **app.js** - Express.js application running on port 3000
2. **package.json** - Node.js application dependencies
3. **conf.d/nodejs-app.conf** - Nginx reverse proxy configuration
4. **nginx.conf** - Main Nginx configuration file

## Quick Start

### 1. Install Node.js Dependencies

```bash
npm install
```

### 2. Start the Node.js Application

```bash
npm start
```

Or for development with auto-reload:

```bash
npm run dev
```

The application will start on http://localhost:3000

### 3. Configure and Start Nginx

First, test the Nginx configuration:

```bash
nginx -t -c /path/to/nginx.conf
```

If the configuration is valid, start or reload Nginx:

```bash
# Start Nginx
nginx -c /path/to/nginx.conf

# Or reload if already running
nginx -s reload
```

### 4. Access the Application

Once both the Node.js app and Nginx are running, access your application at:

- http://localhost (proxied through Nginx)
- http://localhost/health (health check endpoint)
- http://localhost/api/info (API example)

## Configuration Details

### Nginx Reverse Proxy

The `conf.d/nodejs-app.conf` file configures Nginx to:

- Listen on port 80
- Forward all requests to the Node.js app on localhost:3000
- Support WebSocket connections
- Add security headers
- Forward client IP information
- Include h5bp performance and security configurations

### Key Features

- **Upstream keepalive**: Connection pooling for better performance
- **WebSocket support**: Upgrade headers for real-time communication
- **Security headers**: X-Frame-Options, CSP, XSS Protection, etc.
- **Proper request forwarding**: X-Real-IP, X-Forwarded-For, X-Forwarded-Proto
- **Configurable timeouts**: 60s for connect, send, and read operations

## Customization

### Change Server Name

Edit `conf.d/nodejs-app.conf` and replace `localhost` with your domain:

```nginx
server_name yourdomain.com;
```

### Adjust Upload Size

Modify the `client_max_body_size` directive:

```nginx
client_max_body_size 100M;  # Change to desired size
```

### Change Node.js Port

If your Node.js app runs on a different port:

1. Update `app.js` PORT constant
2. Update upstream in `conf.d/nodejs-app.conf`:
   ```nginx
   upstream nodejs_backend {
     server 127.0.0.1:YOUR_PORT;
   }
   ```

## Production Considerations

For production deployments:

1. **Use SSL/TLS**: Use `conf.d/templates/example.com.conf` as a template for SSL configuration
   ```bash
   cp conf.d/templates/example.com.conf conf.d/yourdomain.conf
   # Edit the file to replace example.com with your domain
   # Add SSL certificate paths
   ```
2. **Process Management**: Use PM2 or similar to keep Node.js app running
3. **Environment Variables**: Set NODE_ENV=production
4. **Monitoring**: Configure proper logging and monitoring
5. **Security**: Review and adjust security headers based on your needs

## Troubleshooting

### Check Nginx Configuration

```bash
nginx -t
```

### Check Nginx Error Logs

```bash
tail -f /var/log/nginx/nodejs_app_error.log
```

### Check if Node.js App is Running

```bash
curl http://localhost:3000
```

### Common Issues

1. **Port already in use**: Make sure no other service is using port 3000 or 80
2. **Permission denied**: Run Nginx with appropriate permissions
3. **Connection refused**: Ensure Node.js app is running before starting Nginx

## Application Endpoints

- `GET /` - Welcome message
- `GET /health` - Health check endpoint (returns JSON status)
- `GET /api/info` - API information endpoint

## Additional Resources

- [Nginx Documentation](https://nginx.org/en/docs/)
- [Express.js Documentation](https://expressjs.com/)
- [H5BP Nginx Configs](https://github.com/h5bp/server-configs-nginx)
