FROM node:20-bookworm

RUN apt-get update && apt-get install -y \
  openjdk-17-jre \
  xvfb \
  wget \
  unzip \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# ---- Install Processing (Linux x64 portable) ----
WORKDIR /opt
RUN set -eux; \
  wget -O processing.zip https://github.com/processing/processing4/releases/download/processing-1313-4.5.2/processing-4.5.2-linux-x64-portable.zip; \
  rm -rf /opt/processing_unpack /opt/processing; \
  mkdir -p /opt/processing_unpack; \
  unzip -q processing.zip -d /opt/processing_unpack; \
  rm processing.zip; \
  echo "=== Unpacked tree (top 3 levels) ==="; \
  find /opt/processing_unpack -maxdepth 3 -type d -print; \
  echo "=== Looking for processing-java ==="; \
  PJ="$(find /opt/processing_unpack -type f -name 'processing-java*' | head -n 1)"; \
  echo "Found candidate: ${PJ:-<none>}"; \
  if [ -z "$PJ" ]; then \
    echo "ERROR: processing-java not found. Listing files near top:"; \
    find /opt/processing_unpack -maxdepth 4 -type f | head -n 200; \
    exit 1; \
  fi; \
  chmod +x "$PJ" || true; \
  PROC_DIR="$(dirname "$PJ")"; \
  ln -s "$PROC_DIR" /opt/processing; \
  ls -la /opt/processing

ENV PROCESSING_BIN=/opt/processing/processing-java
ENV PROCESSING_WRAPPER=xvfb-run
ENV PROCESSING_WRAPPER_ARGS=-a

WORKDIR /app
COPY . .

WORKDIR /app/web
RUN npm install && npm install sharp

RUN mkdir -p /app/jobs
ENV JOBS_ROOT=/app/jobs

EXPOSE 3000
CMD ["node", "server.js"]

