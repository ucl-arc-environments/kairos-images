# kairos-images

This repository contains Dockerfiles for building
"[Kairosified](https://kairos.io/docs/reference/kairos-factory/)" images for:

- Almanlinux 10
- [Hadron Linux](https://kairos.io/hadron-docs/)

Container files are also included for
[bundle](https://kairos.io/docs/advanced/bundles/) images for day 2 operations
in kairosified images.

## Releasing

Images and bundles are released independently by creating a
[GitHub release](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository).
The release tag decides what is published:

| Release tag               | Publishes                                          | Workflow                                                         |
| ------------------------- | -------------------------------------------------- | ---------------------------------------------------------------- |
| `images/vX.Y.Z`           | All kairosified images (every distro and k3s pair) | [`publish-kairos.yaml`](.github/workflows/publish-kairos.yaml)   |
| `bundles/<bundle>/vX.Y.Z` | The single bundle in `bundles/<bundle>`            | [`publish-bundles.yaml`](.github/workflows/publish-bundles.yaml) |

Releases with any other tag (including the old `0.0.1` style) publish nothing
and fail the
[`check-release-tag.yaml`](.github/workflows/check-release-tag.yaml) workflow.

Versions must be [semver](https://semver.org/) with a leading `v`, optionally
with a prerelease suffix (e.g. `images/v1.4.0-rc.1`). Marking the GitHub release
as a pre-release controls which image tags are pushed (see below), and promoting
a pre-release to a full release republishes it with the full set of tags.

A change that affects several images or bundles (for example a `kairos-init`
bump) only needs one PR: create a release for each affected tag from the same
merge commit.

Each release is checked against the previous full release in the same namespace
(`images/v*` or `bundles/<bundle>/v*`). If nothing under the corresponding paths
has changed (`images/` and `publish-kairos.yaml` for images, `bundles/<bundle>/`
for a bundle), the workflow fails and nothing is published; delete the release
and tag a commit with changes. Otherwise the commits touching those paths are
written to a `Changes` section of the release notes, between
`<!-- release-scope:... -->` markers. Text outside the markers is kept, except
notes from GitHub's "Generate release notes" button, which list changes from the
whole repository and are removed.

Pull requests may change images or bundles, but not both
([`check-pr-scope.yaml`](.github/workflows/check-pr-scope.yaml)).

New bundles need no workflow changes for publishing; add the bundle to the
matrix in [`build-bundles.yaml`](.github/workflows/build-bundles.yaml) so it is
built on pull requests.

## Kairosified Images

Each release of `images/vX.Y.Z` pushes the following tags to
`ghcr.io/ucl-arc-environments/kairos-<distro>`:

- `<distro-major-version>-k3s<k3s-version>-X.Y.Z` (always)
- `<distro-major-version>-standard-amd64-generic-<kairos-init-version>-k3s<k3s-version>`
  (full releases only; this tag moves to the latest release for that
  combination)

The `+` in k3s versions is replaced with `-` (e.g. `k3sv1.36.5-k3s1`).

The `VERSION` build argument is used by
[`kairos-init`](https://github.com/kairos-io/kairos-init) to populate the
`KAIROS_VERSION` field of the `/etc/kairos-release` file. This value is
important for triggering upgrades using the
[`kairos-operator`](https://github.com/kairos-io/kairos-operator) or
[`system-upgrade-controller`](https://github.com/rancher/system-upgrade-controller).
It is constructed from the release version and the distro (e.g.
`1.4.0-almalinux10`).

## Bundles

Included bundles:

- [calico](./bundles/calico): An image for installing
  [Calico](https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart)
  in the cluster
- [kairos-operator](./bundles/kairos-operator/): An image for installing the
  [kairos-operator](https://github.com/kairos-io/kairos-operator)

Each release of `bundles/<bundle>/vX.Y.Z` pushes
`ghcr.io/ucl-arc-environments/<bundle>-bundle:X.Y.Z`, and also moves `latest`
for full releases.

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
  device: auto
  auto: true
  reboot: true
  image: ghcr.io/ucl-arc-environments/kairos-almalinux:10-standard-amd64-generic-v0.7.1-k3sv1.35.1-k3s1

users:
  - name: kairos
    passwd: kairos
    ssh_authorized_keys:
      - ...

bundles:
  - targets:
      - run://ghcr.io/ucl-arc-environments/kairos-operator-bundle:0.0.1

k3s:
  enabled: true
```
