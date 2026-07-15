FROM alpine:3.24@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS build

# hadolint ignore=DL3018
RUN apk add --no-cache ca-certificates curl

# Install kubectl for kustomize
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# renovate: depName=tigera-operator repoUrl=https://docs.tigera.io/calico/charts
ARG CALICO_VERSION=v3.32.1

# Download the Calico manifests for the specified version
RUN curl -L -o /tmp/v1_crd_projectcalico_org.yaml \
  "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/v1_crd_projectcalico_org.yaml" && \
  curl -L -o /tmp/tigera-operator.yaml \
  "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/tigera-operator.yaml" && \
  curl -L -o /tmp/custom-resources.yaml \
  "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/custom-resources.yaml"

FROM scratch
COPY --from=build /usr/local/bin/kubectl /assets/kubectl
COPY --from=build /tmp/v1_crd_projectcalico_org.yaml /assets/v1_crd_projectcalico_org.yaml
COPY --from=build /tmp/tigera-operator.yaml /assets/tigera-operator.yaml
COPY --from=build /tmp/custom-resources.yaml /assets/custom-resources.yaml
COPY ./overlays /assets/overlays
COPY ./run.sh /
