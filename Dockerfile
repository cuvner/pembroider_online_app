
FROM node:20-bookworm
RUN apt-get update && apt-get install -y openjdk-17-jre xvfb wget && rm -rf /var/lib/apt/lists/*
WORKDIR /opt
RUN wget https://github.com/processing/processing4/releases/download/processing-4.3/processing-4.3-linux-x64.tgz  && tar -xzf processing-4.3-linux-x64.tgz
ENV PROCESSING_BIN=/opt/processing-4.3/processing-java
ENV PROCESSING_WRAPPER=xvfb-run
ENV PROCESSING_WRAPPER_ARGS=-a
WORKDIR /app
COPY . .
WORKDIR /app/web
RUN npm install
EXPOSE 3000
CMD ["node","server.js"]
