# Resulting container is 398 MB

# Use the official Swift image.
# This is current swift:5.7
# https://hub.docker.com/_/swift
# This container is 2.15 GB
# FROM swift:latest as builder
FROM swift:5.7 as builder

# Copy local code to the container image.
WORKDIR /app
COPY . .

# Install dependencies and build.
RUN swift build -c release

# This container is 395 MB
FROM swift:slim

WORKDIR /app

# swift build -c release --show-bin-path
COPY --from=builder /app/.build/x86_64-unknown-linux-gnu/release/SwiftRequest .
RUN mkdir -p /app/public
COPY --from=builder /app/public/favicon.ico public/favicon.ico

# Run the web service on container startup.
CMD [ "/app/SwiftRequest"]
