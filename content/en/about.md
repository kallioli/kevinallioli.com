---
title: "About"
translationKey: "about"
description: "OpenStack engineer in Geneva. Thirteen years of infrastructure, five of them running OpenStack past 5,000 servers, and upstream fixes since 2026."
---

I am an OpenStack engineer. For thirteen years I have built and operated
infrastructure, and for five of those years I ran OpenStack clouds of more
than 5,000 servers. Today I fix upstream what I used to meet in operations,
and I am looking for a position where OpenStack is the core of the job.

## What I do

**Operate OpenStack at scale.** Nova, Neutron, Cinder, Keystone, Placement,
and what carries them: the database, the message queue, the storage. Level
3 incidents, the ones with no documentation page, and the weak signals that
come before them.

**Upgrade a platform.** Prepare, test what can be tested, decide what will
not be, execute inside the window, and know on which criterion to roll
back. An upgrade plan and its execution are never the same document.

**Build system images.** The layer almost nobody looks at and everything
else inherits from. Reproducible builds, signatures, embedded provenance.
That is what [Open Image Cloud](/en/projects/open-image-cloud/) is about.

**Contribute upstream.** Codebase modernisation and security fixes on
Horizon, the OpenStack dashboard, and on openstacksdk. Code reviews on
Horizon, openstacksdk and Keystone. The [register](/en/contributions/)
lists everything, abandoned changes included.

**Automate.** Terraform and Ansible for multi-cloud clusters, GitHub
Actions for build pipelines. Reversibility is settled before the migration,
not after.

**Teach.** Public Cloud training and technical support for teams adopting
the cloud.

## The field

I am now an N3 Cloud and Managed Services engineer at Cheops Technology
Switzerland, in Geneva.

Before that, for five years at Infomaniak, I operated and evolved OpenStack
environments of more than 5,000 servers. Upgrades, scale-up, level 3
incidents, multi-cloud clusters driven by Terraform and Ansible. At that
scale the official documentation describes the procedure; it does not
describe what happens when the procedure meets what is already there. That
gap is what interests me, and it is where nearly everything I know comes
from.

I also designed the system images those machines boot on. It is the layer
almost nobody looks at, and precisely the one that decides: whatever it
contains, everything else inherits.

## What I publish

[Open Image Cloud](/en/projects/open-image-cloud/) is the logical
continuation of that work: ready-to-use cloud images for OpenStack and
Proxmox, built reproducibly on GitHub Actions, signed with keyless cosign,
and shipped with their provenance embedded in a `MANIFEST.json`. Eight
Linux distributions, plus Octavia amphorae pinned to each OpenStack
release.

The goal fits in one sentence: you can verify what you boot without having
to trust me.

## Upstream

Fixing a problem at home solves it once; fixing it upstream solves it for
everyone. I contribute to OpenStack under the Gerrit account `kallioli`
since 2026: modernisation (Python 3.14, Django 6.0) and security fixes on
Horizon, and on openstacksdk.

The [contributions register](/en/contributions/) says it as it is: merged
changes, changes in review, abandoned ones, with a link to each review. An
abandoned patch, owned, says more than a list where only successes appear.

## What I believe

Sovereignty is not declared, it is verified. Infrastructure you cannot
rebuild from source is not sovereign, whatever country the datacentre sits
in. Geography is a condition; it has never been a proof.

## What I am looking for

A position as an OpenStack engineer or architect: operations at scale,
upgrades, image pipelines, or upstream work. A team that runs OpenStack in
production and has problems with no documentation page.

## Write

By email: [kevin@stackops.ch](mailto:kevin@stackops.ch). The code is on
[GitHub](https://github.com/kallioli), the reviews on
[Gerrit](https://review.opendev.org/q/owner:kallioli), the career on
[LinkedIn](https://www.linkedin.com/in/kevin-allioli).
