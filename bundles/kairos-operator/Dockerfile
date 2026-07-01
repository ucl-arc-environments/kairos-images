FROM alpine:3.24@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS build

# renovate: datasource=github-releases depName=kairos-io/kairos-operator
ENV VERSION=0.0.7

# Install kubectl for kustomize and git
# hadolint ignore=DL3018
RUN apk add --no-cache curl git
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Clone the repository at the specific tag version
RUN git clone --depth 1 --branch v${VERSION} https://github.com/kairos-io/kairos-operator.git /tmp/kairos-operator

# Generate the kairos-operator manifest using the specific version
WORKDIR /tmp/kairos-operator/config/default
RUN kubectl kustomize . > /kairos-operator.yaml

FROM scratch
COPY --from=build /kairos-operator.yaml /assets/kairos-operator.yaml
COPY ./run.sh /
