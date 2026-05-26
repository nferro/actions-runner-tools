# actions-runner-tools

Custom Linux runner image for the **dotpt-linux-dind** ARC scale set (Talos K8s,
see [`dotpt-private/argocd`](https://github.com/dotpt-private/argocd)).

`FROM ghcr.io/actions/actions-runner:latest` plus the tools that GitHub-hosted
`ubuntu-latest` ships with but the lean base image omits:

- `gh`, `jq`, `git`, `curl`, `wget`, `unzip`, `xz-utils`, `zstd`, `gnupg`,
  `ca-certificates`, `build-essential`
- `docker-buildx-plugin`, `docker-compose-plugin` (talk to the DinD sidecar)

## Build

- `.github/workflows/build.yml` builds on push to `main` (or via
  `workflow_dispatch`) and pushes:
  - `ghcr.io/dotpt-private/actions-runner-tools:latest`
  - `ghcr.io/dotpt-private/actions-runner-tools:<sha>`
- Builds run on `ubuntu-latest`, not on the ARC pool this image targets.
  Rationale: an image builder must never depend on the image it produces — a
  broken push would otherwise prevent building the fix.

## Visibility

First publish creates the ghcr package as private. After the first successful
build, manually set visibility to public at
<https://github.com/orgs/dotpt-private/packages/container/actions-runner-tools/settings>
so the cluster can pull without an imagePullSecret.

## Consumer

`dotpt-private/argocd` → `applications/arc-runners-dotpt-linux-dind.yaml`,
under `helm.values` → `template.spec.containers[0].image`.
