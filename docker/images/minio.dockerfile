# Upstream minio/minio images were removed from Docker Hub and Quay,
# so build the pinned release from source.
FROM golang:1.25-alpine AS build

ARG MINIO_RELEASE=RELEASE.2025-04-22T22-12-26Z

RUN apk add --no-cache git curl

WORKDIR /src
RUN curl -fsSL https://github.com/minio/minio/archive/refs/tags/${MINIO_RELEASE}.tar.gz \
        | tar xz --strip-components=1

RUN CGO_ENABLED=0 GOAMD64=v1 go build -trimpath \
        -ldflags "-s -w -X github.com/minio/minio/cmd.Version=${MINIO_RELEASE}" \
        -o /out/minio .

FROM alpine:3.22

RUN apk add --no-cache ca-certificates curl
COPY --from=build /out/minio /usr/bin/minio

EXPOSE 9000 9001
VOLUME ["/data"]
ENTRYPOINT ["/usr/bin/minio"]
CMD ["server", "/data"]
