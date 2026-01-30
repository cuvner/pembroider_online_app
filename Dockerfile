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
RUN wget -O processing.zip \
    https://github.com/processing/processing4/releases/download/processing-1313-4.5.2/processing-4.5.2-linux-x64-portable.zip \
 && unzip processing.zip -d /opt \
 && rm processing.zip \
 && sh -c 'PROC_DIR="$(ls -d /opt/processing-* | head -n 1)"; echo "Detected: $PROC_DIR"; ln -s "$PROC_DIR" /opt/processing'

ENV PROCESSING_BIN=/opt/processing/processing-java
ENV PROCESSING_WRAPPER=xvfb-run
ENV PROCESSING_WRAPPER_ARGS=-a

WORKDIR /app
COPY . .

WORKDIR /app/web
RUN npm install && npm install sharp

RUN mkdir -p /app/jobs

ENV JOBS_ROOT=/app/jobs
ENV MAX_CONCURRENT=1
ENV MAX_FILES=6
ENV MAX_FILE_MB=10
ENV RENDER_TIMEOUT_MS=120000

EXPOSE 3000
CMD ["node", "server.js"]

