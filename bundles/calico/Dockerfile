FROM alpine:3.24@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6 AS build

# hadolint ignore=DL3018
RUN apk add --no-cache ca-certificates curl

# Install kubectl for kustomize
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# renovate: datasource=github-releases depName=projectcalico/calico
ARG CALICO_VERSION=v3.32.1

# Download the Calico manifests for the specified version
RUN curl -L -o /tmp/v1_crd_projectcalico_org.yaml \
  "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/v1_crd_projectcalico_org.yaml" && \
  curl -L -o /tmp/tigera-operator.yaml \
  "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/tigera-operator.yaml" && \
  curl -L -o /tmp/calico-custom-resources.yaml \
  "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/custom-resources.yaml"

FROM scratch
COPY --from=build /usr/local/bin/kubectl /assets/kubectl
COPY --from=build /tmp/v1_crd_projectcalico_org.yaml /assets/v1_crd_projectcalico_org.yaml
COPY --from=build /tmp/tigera-operator.yaml /assets/tigera-operator.yaml
COPY --from=build /tmp/calico-custom-resources.yaml /assets/calico-custom-resources.yaml
COPY ./overlays /assets/overlays
COPY ./run.sh /
