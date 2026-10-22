FROM alpine:3.24

RUN apk add --no-cache 'zlib>=1.3.2-r1'

WORKDIR /

COPY devenv/bin/manager /manager

ENTRYPOINT ["/manager"]
