FROM --platform=$BUILDPLATFORM docker.io/golang:1.21-alpine3.18 as builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH

ENV CGO_ENABLED=0
ENV GO111MODULE=on

# hadolint ignore=DL3018
RUN uname -a && apk update && apk add --no-cache \
    bash \
    gcc \
    git \
    make \
    musl-dev

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .

RUN uname -a &&\
    CGO_ENABLED=${CGO_ENABLED} GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    make build && make cel-key

FROM debian:buster-slim

# Read here why UID 10001: https://github.com/hexops/dockerfile/blob/main/README.md#do-not-use-a-uid-below-10000
ARG UID=10001
ARG GID=10001
ARG USER_NAME=celestia

ENV CELESTIA_HOME=/home/${USER_NAME}

# Default node type can be overwritten in deployment manifest
ENV NODE_TYPE bridge
ENV P2P_NETWORK mocha

RUN apt-get update && apt-get --assume-yes --no-install-recommends install \
        curl \
        bash \
        jq \ 
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*


RUN groupadd --gid ${GID} celestia \
  && useradd --create-home --no-log-init -u ${UID} -g ${GID} celestia

# Copy in the binary
COPY --from=builder /src/build/celestia /bin/celestia
COPY --from=builder /src/./cel-key /bin/cel-key

COPY --chown=${USER_NAME}:${USER_NAME} docker/entrypoint.sh /opt/entrypoint.sh

EXPOSE 2121

ENTRYPOINT [ "/bin/bash", "/opt/entrypoint.sh" ]
