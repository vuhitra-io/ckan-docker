FROM ckan/ckan-dev:2.10.4

# Install dependencies (for inotifywait and supervisor)
RUN apk update && apk add --no-cache inotify-tools supervisor rsync nodejs npm
RUN npm install -g webpack webpack-cli

# Copy your inotify script into the container
COPY watch_sync.sh /root/watch_sync.sh
RUN chmod +x /root/watch_sync.sh

# Copy custom initialization scripts
COPY docker-entrypoint.d/* /docker-entrypoint.d/
