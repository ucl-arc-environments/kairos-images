# kairos-images

This repository contains Dockerfiles for building
"[Kairosified](https://kairos.io/v3.5.2/docs/advanced/creating_custom_cloud_images/)"
images for both AlmaLinux 9 and AlmaLinux 10 and
[bundle](https://kairos.io/docs/advanced/bundles/) images for day 2 operations
in kairosified images.

## kairosified images

The Docker tags for kairosified images are constructed as follows:
`<almalinux-major-version>-standard-amd64-generic-<kairos-init-version>-k3s<k3s-version>`

The repository release tag uses the release date in `YYYYMMDD` format, suffixed
with a with a revision number (e.g. `20250911.1`).

The `VERSION` build argument is used by
[`kairos-init`](https://github.com/kairos-io/kairos-init) to populate the
`KAIROS_VERSION` field of the `/etc/kairos-release` file. This value is
important for triggering upgrades using the
[`kairos-operator`](https://github.com/kairos-io/kairos-operator) or
[`system-upgrade-controller`](https://github.com/rancher/system-upgrade-controller).
In this repository it is constructed when the
[`release.yaml`](.github/workflows/release.yaml) workflow executes by combining
the Almalinux major version and the Github release tag (e.g. `9.20250911.1`).

## Bundles

Included bundles:

- [kairos-operator](./bundles/kairos-operator/): An image for installing the
  [kairos-operator](https://github.com/kairos-io/kairos-operator)

Bundles in this repo can be used as follows:

```yaml
bundles:
  - targets:
      - run://ghcr.io/ucl-arc-environments/<bundle-name>-bundle:<image-tag>
```

To use when deploying a kairosified image:

```yaml
#cloud-config
install:
  device: "auto"
  auto: true
  reboot: true
  image: "ghcr.io/ucl-arc-environments/kairos-almalinux:10-standard-amd64-generic-v0.7.1-k3sv1.35.1-k3s1"

users:
  - name: "kairos"
    passwd: "kairos"
    ssh_authorized_keys:
      - ...

bundles:
  - targets:
      - run://ghcr.io/ucl-arc-environments/kairos-operator-bundle:0.0.1

k3s:
  enabled: true
```