---
title: "About"
translationKey: "about"
description: "Thirteen years of infrastructure, five of them running OpenStack past 5,000 servers, and one conviction about what sovereign means."
---

A sovereign cloud is not a label on a brochure. It is being able to
rebuild, from source and verifiably, the system image that boots on
thousands of servers. That is the work I have been doing for thirteen
years, and it is the project I publish as open source.

## The ground

For five years, at Infomaniak, I operated and evolved OpenStack
environments of more than 5,000 servers: version upgrades, scale-up, level
3 incidents, multi-cloud clusters driven by Terraform and Ansible. At that
scale the official documentation describes the procedure; it does not
describe what happens when the procedure meets what is already there. That
gap is what interests me, and it is where nearly everything I know comes
from.

I also designed the system images those machines boot on. It is the layer
almost nobody looks at, and precisely the one that decides: whatever it
contains, everything above inherits.

I am now an N3 Cloud and Managed Services engineer at Cheops Technology
Switzerland, in Geneva.

## What I publish

[Open Image Cloud](/en/projects/open-image-cloud/) is the logical
continuation of that work: ready-to-use cloud images for OpenStack and
Proxmox, built reproducibly on GitHub Actions, signed with keyless cosign,
and shipped with their provenance embedded in a `MANIFEST.json`. Eight
Linux distributions, plus Octavia amphorae pinned to each OpenStack
release.

The goal fits in one sentence: you can verify what you boot without having
to trust me. That is the whole point, and it is also the only honest way
to say the word sovereignty.

## Upstream

Fixing a problem locally fixes it once; fixing it upstream fixes it for
everyone. I have recently started contributing to OpenStack under the
Gerrit account `kallioli`: modernisation and security fixes on Horizon,
the OpenStack dashboard, and on openstacksdk.

It is recent, and the [contributions register](/en/contributions/) says so
plainly: merged changes, changes in review, and abandoned ones, each with
a link to its review.

## Getting in touch

By email: [kevin@stackops.ch](mailto:kevin@stackops.ch). Code on
[GitHub](https://github.com/kallioli), reviews on
[Gerrit](https://review.opendev.org/q/owner:kallioli).
