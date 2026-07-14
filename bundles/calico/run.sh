#!/bin/bash

set -ex

K3S_MANIFEST_DIR="/var/lib/rancher/k3s/server/manifests/"

mkdir -p $K3S_MANIFEST_DIR

# renovate: depName=tigera-operator repoUrl=https://docs.tigera.io/calico/charts
VERSION="v3.32.1"

_version=$(kairos-agent config get "calico.version" | tr -d '\n')
if [ "$_version" != "null" ]; then
    VERSION=$_version
fi

MTU=1450
_mtu=$(kairos-agent config get "calico.mtu" | tr -d '\n')
if [ "$_mtu" != "null" ]; then
  MTU=$_mtu
fi

# download the calico manifests
v1_crd_url="https://raw.githubusercontent.com/projectcalico/calico/${VERSION}/manifests/v1_crd_projectcalico_org.yaml"
curl -L -o assets/v1_crd_projectcalico_org.yaml "${v1_crd_url}"
tigera_operator_url="https://raw.githubusercontent.com/projectcalico/calico/${VERSION}/manifests/tigera-operator.yaml"
curl -L -o assets/tigera-operator.yaml "${tigera_operator_url}"
calico_cr_url="https://raw.githubusercontent.com/projectcalico/calico/${VERSION}/manifests/custom-resources.yaml"
curl -L -o assets/custom-resources.yaml "${calico_cr_url}"

# patch the cr manifest to include mtu under calicoNetwork
sed -i "s/calicoNetwork:/calicoNetwork:\n    mtu: ${MTU}/" assets/custom-resources.yaml
