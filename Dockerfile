FROM golang:alpine3.13
RUN mkdir -p /go
RUN mkdir -p /app
COPY . /go/src/github.com/Ullaakut/cameradar
COPY ./dictionaries /app/dictionaries

WORKDIR /go/src/github.com/Ullaakut/cameradar/cmd/cameradar

RUN apk upgrade && \
    apk add nmap \
    nmap-nselibs \
    nmap-scripts \
    gcc \
    libc-dev \
    git \
    curl==7.79.1-r3 \
    curl-dev==7.79.1-r3

ENV GO111MODULE=on
RUN go version
RUN go build -o cameradar

# Necessary to install curl v7.64.0-r3.
# Fix for https://github.com/Ullaakut/cameradar/issues/247
RUN sed -i 's/v3.13/v3.9/g' /etc/apk/repositories

RUN apk add --no-cache nmap \
    nmap-nselibs \
    nmap-scripts \
    curl-dev==7.64.0-r5 \
    curl==7.64.0-r5

WORKDIR /app
RUN cp /go/src/github.com/Ullaakut/cameradar/cmd/cameradar /app/cameradar

ENV CAMERADAR_CUSTOM_ROUTES="/app/dictionaries/routes"
ENV CAMERADAR_CUSTOM_CREDENTIALS="/app/dictionaries/credentials.json"

ENTRYPOINT ["/app/cameradar"]
