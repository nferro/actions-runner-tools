# actions-runner-tools

Linux runner image for [Actions Runner Controller](https://github.com/actions/actions-runner-controller) scale sets.

`FROM ghcr.io/actions/actions-runner:latest` plus the tools GitHub-hosted
`ubuntu-latest` ships with but the lean base image omits:

- `gh`, `jq`, `git`, `curl`, `wget`, `unzip`, `xz-utils`, `zstd`, `gnupg`,
  `ca-certificates`, `build-essential`
- `docker-buildx-plugin`, `docker-compose-plugin` (talk to an in-pod DinD sidecar)

## Use

```yaml
# in your gha-runner-scale-set Helm values
template:
  spec:
    containers:
      - name: runner
        image: ghcr.io/nferro/actions-runner-tools:latest
        command: ["/home/runner/run.sh"]
```

Pin to `:<sha>` rather than `:latest` if you want reproducible rollouts.

## Build

- `.github/workflows/build.yml` builds on push to `main` (or via
  `workflow_dispatch`) and pushes:
  - `ghcr.io/nferro/actions-runner-tools:latest`
  - `ghcr.io/nferro/actions-runner-tools:<sha>`
- Builds run on `ubuntu-latest`, not on the runner pool this image targets.
  Rationale: an image builder must never depend on the image it produces — a
  broken push would otherwise prevent building the fix.

## Visibility

First publish creates the ghcr package as private. After the first successful
build, set visibility to public at
<https://github.com/users/nferro/packages/container/actions-runner-tools/settings>
so consumers can pull without an imagePullSecret.
