#!/bin/bash

set -ex

K3S_MANIFEST_DIR="/var/lib/rancher/k3s/server/manifests/"

# get the calico CONFIG from the config and set them to the CONFIG variable if they exist
_config=$(kairos-agent config get "calico.extraConfig | @json" | tr -d '\n')

# Remove the quotes wrapping the value.
_config=${_config:1:${#_config}-2}
if [ "$_config" != "null" ]; then
    CONFIG=$_config
fi

if [ -n "$CONFIG" ]; then
  # template the calico installation overlay with the CONFIG from the config
  sed -i "s/@CONFIG@/${CONFIG}/g" "assets/overlays/installation.yaml"

  # kustomize the calico custom resources
  cp assets/calico-custom-resources.yaml assets/overlays/calico-custom-resources.yaml
  kubectl kustomize assets/overlays > assets/calico-custom-resources.yaml
fi

# copy the calico manifests to the k3s manifest directory
mkdir -p $K3S_MANIFEST_DIR
cp -f assets/* $K3S_MANIFEST_DIR
