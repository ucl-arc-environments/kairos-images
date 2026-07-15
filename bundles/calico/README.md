# Calico Bundle

The calico bundle deploys
[Project Calico](https://docs.tigera.io/calico/latest/about/).

## Configuration

To configure the bundle, use the `calico` block:

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://ghcr.io/ucl-arc-environments/calico-bundle:latest

# Specify calico extra config that will be merged with `calicoNetwork`
calico:
  extraConfig:
    calicoNetwork:
      bgp: Disabled
      mtu: 1450
```

Note that `extraConfig` will be merged with the `spec` block of the
`Installation` resource in the Calico
[custom resources manifests](https://github.com/projectcalico/calico/blob/master/manifests/custom-resources.yaml).
