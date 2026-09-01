---
title: "Open Image Cloud"
type: projects
translationKey: "oic"
weight: 10
description: "Cloud images for OpenStack and Proxmox: reproducible builds, keyless cosign signatures, provenance embedded in every image."
status: "Active - eight Linux distributions, plus Octavia amphorae"
facts:
  - key: "site"
    value: "openimages.cloud"
    url: "https://openimages.cloud"
  - key: "registry"
    value: "images.openimages.cloud"
    url: "https://images.openimages.cloud"
  - key: "code"
    value: "github.com/open-img-cloud"
    url: "https://github.com/open-img-cloud"
  - key: "licence"
    value: "Apache-2.0 / MIT depending on the repository"
  - key: "role"
    value: "Author and maintainer"
links:
  - label: "openimages.cloud"
    url: "https://openimages.cloud"
  - label: "github.com/open-img-cloud"
    url: "https://github.com/open-img-cloud"
---

Open Image Cloud publishes ready-to-use cloud images for OpenStack and
Proxmox. Eight Linux distributions (Alpaquita, Alpine, Amazon Linux 2 and
2023, Gentoo, NixOS, Oracle Linux 9 and 10), plus Octavia amphorae pinned
to each OpenStack release.

What separates these images from a distribution's official ones is not
their contents. It is what you can say about them with certainty.

## The problem

You boot a cloud image. It came from a mirror, it has a filename and a
checksum. The checksum proves the file was not altered after publication.
It says nothing about what happened before: which repository, which
revision, which machine, which packages at which date, which changes
applied after the base install.

On one machine that is a detail. On a fleet it is the layer everything else
inherits from, and the only one nobody reads.

## What is in place

**Reproducible builds.** Every image is built by a GitHub Actions workflow
from pinned upstream sources and a tagged builder container. The commit,
the build run URL and the builder container digest are written into the
`MANIFEST.json` shipped next to the image.

**Keyless cosign signatures.** Images are signed through GitHub Actions
OIDC. There is no private key to keep, so there is no private key to lose.
Verification runs against the identity of the workflow that produced the
image:

```bash
cosign verify-blob alpine-3.23.4-uefi-x86_64.qcow2 \
  --bundle alpine-3.23.4-uefi-x86_64.qcow2.bundle --new-bundle-format \
  --certificate-identity-regexp 'https://github.com/open-img-cloud/' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

**Immutable paths.** The public registry serves images under
`images.openimages.cloud/<os>/<version>/<filename>`. A published path never
changes. A mutable `latest/` alias exists alongside it for those who want
one, but it is never the reference.

## Architecture

The build pipeline lives in a shared `.github` repository as reusable
workflows and composite actions. Each image repository stays thin: a
`VERSION`, a customisation script (libguestfs or diskimage-builder
depending on the distribution), an upstream version watcher, and two
caller workflows.

For storage, the source of truth is a self-hosted
[Garage](https://garagehq.deuxfleurs.fr) cluster, mirrored to Cloudflare R2
and served behind the CDN. A small Worker routes `/<os>/*` paths to the
matching buckets.

## Why it matters

The word sovereign is currently sold as a geographic property. But a
datacentre in Europe booting images whose lineage nobody can reconstruct
gives you no additional guarantee: it moves the trust, it does not remove
it.

The point of Open Image Cloud is to make that trust unnecessary. You can
verify what you boot without having to believe me.
