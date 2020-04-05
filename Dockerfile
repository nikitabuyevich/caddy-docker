############################
# STEP 1 build executable binary
############################
# golang debian buster 1.14.1 linux/amd64
# https://github.com/docker-library/golang/blob/master/1.14/buster/Dockerfile
FROM golang:1.14.1-alpine@sha256:75233bee4a369270695c7e0718c35ee1ab153273684f2b4f669e3c1302c6a36c as builder

# args
# TODO: Upgrade to v2 once it's out of beta
# Caddy server version
ARG VERSION="1.0.4"
# add plugin import paths here separated by commas
ARG PLUGINS="github.com/caddyserver/dnsproviders/cloudflare"
# Send data to Caddy Server
ARG TELEMETRY="false"
# Whether or not to run UPX to compress static binary
ARG COMPRESS="true"

# Set the working directory and copy its contents
# build root
WORKDIR /build

# plugins
COPY plugger.go ./

# build & test
RUN apk add --no-cache ca-certificates \
    && printf "module caddy\nrequire github.com/caddyserver/caddy v${VERSION}" > go.mod \
    && go run plugger.go -plugins="${PLUGINS}" -telemetry="${TELEMETRY}" \
    && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags='-w -s -extldflags "-static"' -a \
    && ./caddy -version

RUN if [ "$COMPRESS" = "true" ]; then \
    # Install upx
    apk add --no-cache upx; \
    # Compress binary
    upx --ultra-brute caddy; \
    fi;


############################
# STEP 2 build a small image
############################
# Using static nonroot image
# User:group is nobody:nobody, uid:gid = 65534:65534
# Get the sha256 from the "latest" tagged image
FROM gcr.io/distroless/static@sha256:c6d5981545ce1406d33e61434c61e9452dad93ecd8397c41e89036ef977a88f4

# copy binary and ca certs
COPY --from=builder /build/caddy /bin/caddy
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# copy default caddyfile
COPY Caddyfile /etc/Caddyfile

# set default caddypath
ENV CADDYPATH=/etc/.caddy

# Run the app
ENTRYPOINT ["/bin/caddy", "--conf", "/etc/Caddyfile", "--log", "stdout"]
