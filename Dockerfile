# Build stage
FROM golang:alpine AS build-env

COPY . /go/src/github.com/Ullaakut/cameradar
WORKDIR /go/src/github.com/Ullaakut/cameradar/cmd/cameradar

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.13/main' >> `/etc/apk/repositories`

RUN apk update && \
    apk add nmap nmap-nselibs nmap-scripts \
    gcc \
    libc-dev \
    git \
    pkgconfig \
    curl==7.79.1-r3 \
    curl-dev==7.79.1-r3
ENV GO111MODULE=on
RUN go version
RUN go build -o cameradar

# Final stage
FROM alpine

# Necessary to install curl v7.64.0-r3.
# Fix for https://github.com/Ullaakut/cameradar/issues/247
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.9/main' >> /etc/apk/repositories

RUN apk --update add --no-cache nmap \
    nmap-nselibs \
    nmap-scripts \
    curl-dev==7.64.0-r5 \
    curl==7.64.0-r5

WORKDIR /app/cameradar
COPY --from=build-env /go/src/github.com/Ullaakut/cameradar/dictionaries/ /app/dictionaries/
COPY --from=build-env /go/src/github.com/Ullaakut/cameradar/cmd/cameradar/ /app/cameradar/

ENV CAMERADAR_CUSTOM_ROUTES="/app/dictionaries/routes"
ENV CAMERADAR_CUSTOM_CREDENTIALS="/app/dictionaries/credentials.json"

ENTRYPOINT ["/app/cameradar/cameradar"]
