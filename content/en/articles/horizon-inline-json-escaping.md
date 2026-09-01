---
title: "Why JSON embedded in a Horizon page deserved proper escaping"
date: 2026-10-20
draft: true
description: "A security fix on the OpenStack dashboard, and the class of problem it belongs to."
pillar: "Upstream"
tags: ["openstack", "horizon", "security", "django"]
---

*Outline only. The body rests on precise work on
[change 1002877](https://review.opendev.org/c/openstack/horizon/+/1002877),
which is in review at the time of writing and which I am the only one able
to describe accurately.*

## The pattern

*Serialising server-side data into an inline `<script>` block, and why it
is so common in dashboards.*

## Why HTML escaping and JavaScript escaping are not the same problem

### How the HTML parser reads a script block

### The sequences that end it early

## What that allows

*The class of issue, described at the level of the mechanism rather than as
a recipe.*

## What Django gives you

### `json_script` and what it guarantees

### Why a template filter is not enough on its own

## The change

*What it touches, what it deliberately does not touch, and how it was
reviewed. Link to the Gerrit change.*

## The general rule

*Where else this pattern appears in an operator's own code.*
