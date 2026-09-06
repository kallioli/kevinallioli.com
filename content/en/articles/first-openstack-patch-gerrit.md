---
title: "Sending your first patch to OpenStack: Gerrit, the review workflow, and what nobody explains"
date: 2026-10-13
draft: true
description: "The mechanics of contributing upstream to OpenStack, from account setup to a merged change, including the parts the official guide leaves out."
pillar: "Upstream"
tags: ["openstack", "gerrit", "upstream", "contributing"]
---

My first change to OpenStack was uploaded on 8 October 2024. It failed the
check pipeline twice that same day, collected a negative review two weeks
later, sat untouched for seven months, and was abandoned in May 2025 by a
maintainer doing routine housekeeping, with the entirely reasonable comment
that it was a patch without activity for multiple years.

In September 2026 I restored it and pushed a third patch set that fixes
what the reviewer had asked for. The change is
[931759](https://review.opendev.org/c/openstack/horizon/+/931759), it is
public, and every step of that history is readable by anyone.

I am starting there on purpose. Most accounts of a first upstream
contribution are written from the far side, once it merged, and they leave
out the part that actually decides whether you come back.

## Why upstream at all

Carrying a patch locally works. It also means you own it forever: every
version bump is a rebase, every incident is one more thing to remember, and
the knowledge of why the patch exists leaves when you do.

Upstreaming trades that for a slower, more public process. The trade is
worth making when the bug is not specific to you, which is more often than
it feels. The bug in 931759 is a Horizon page raising `ValueError` when
neutron does not expose an extension. Nothing about that is particular to
one operator.

## The setup nobody documents in one place

### Accounts, the CLA, and the Gerrit identity

You need an account on the OpenDev Gerrit at `review.opendev.org`, and for
OpenStack projects you need to sign the Individual Contributor License
Agreement. That is done once, inside Gerrit.

The step that is easy to get wrong is the identity. Gerrit matches the
author of your commit against the email addresses registered on your
account. If the address in your `git config` is not one of them, the push is
rejected, and the message you get back is not particularly explicit about
why. Register the address you actually commit with before you push anything.

### `git-review` and what it does to your branch

Contributions do not arrive as pull requests. Gerrit reviews individual
commits, and `git-review` is the tool that speaks its protocol:

```bash
git checkout -b my-topic
# edit, then
git commit -a
git review
```

Two things it does are worth understanding rather than accepting.

It installs a commit hook that adds a `Change-Id` footer to your commit
message. That identifier, not the branch name and not the commit SHA, is
what ties every later revision of your work to the same review. Lose it and
you open a second, unrelated change.

And it pushes to a magic ref rather than to a branch. Your topic branch never
exists on the server. What exists is a change with a number, and successive
patch sets attached to it.

## Your first change

### Choosing something small enough to finish

The advice usually given is to pick something small. The better framing is to
pick something you can still defend six months later, because that may well
be the timescale.

Mine was not small enough. It touched a constructor, needed test coverage I
had not written, and the tests are exactly what the review came back about.

### The commit message is part of the review

Reviewers read the message before the diff, and they review the message too.
It should say what breaks, under what conditions, and why this is the right
place to fix it. If you have a bug number, `Closes-Bug: #NNNNNN` in the
footer links them.

## What happens after you push

### Zuul, the check pipeline, and reading a failed job

Zuul runs the check pipeline and votes. A `Verified-1` means a job failed,
and the vote comes with a link to the logs.

Both of my first two patch sets got `Verified-1` on the day I pushed them.
That is normal and it is not a rejection. It is the first useful thing that
happens, because it is a reviewer that answers in minutes rather than in
weeks.

### Recheck, and when not to

Commenting `recheck` runs the pipeline again. It exists because some failures
are infrastructure, not code.

Use it when you have a reason to believe the failure was not yours. Using it
as a reflex burns shared CI capacity and, worse, teaches you nothing. Read
the log first. If the same job fails the same way twice, it is yours.

## The review itself

### Reading a minus one without taking it personally

On 22 October 2024, Tatiana Ovchinnikova left a `Code-Review-1` with one
comment on the tests. That is a request for changes, not a verdict on the
idea.

The thing nobody tells you is what a negative review costs in momentum. It
does not feel like a queue of work. It feels like the door closing, and if
you are contributing on your own time, on top of a job, the gap between
reading it and acting on it is where most first contributions die. Mine sat
for seven months in exactly that gap.

### Patch sets, rebases, and keeping the discussion attached

A revision is a new patch set on the same change, not a new change. You amend
your commit, keeping the `Change-Id`, and run `git review` again. Reviewers
can then diff patch set 2 against patch set 3 and see only what you changed
in response to them.

Gerrit also decides which votes survive a new patch set, through copy
conditions configured per project. On my change both were dropped, and the
reasons differ: the CI vote is never copied, while the review vote is copied
only on a trivial rebase or when it is the minimum value on the scale. Patch
set 3 was neither, so the review had to be given again.

## When a change is abandoned

In May 2025, Jan Jasek abandoned 931759 for inactivity. That is maintenance,
not rejection: a review queue full of two-year-old changes nobody is working
on helps nobody, least of all the people trying to find what still needs
attention.

Abandoning is reversible. Anyone with the rights can restore a change, and
the whole history comes back with it. What I wrote when I restored it is the
part that matters:

The underlying bug is still present on master. `PortForwarding.__init__`
calls `int()` on the result of `.get("internal_port_range", "")`, and
openstacksdk omits that key entirely from `to_dict()` when neutron does not
expose the port ranges extension, so the `ValueError` is still reachable
today.

That is the only argument that justifies restoring anything: not that I had
put work into it, but that the problem it describes has not gone away.

Patch set 3 addresses the review from two years earlier. Four test cases,
three of which fail without the production change, and one that guards the
existing sorting and deduplication against regression. It also fixes a second
latent failure that patch set 2 had: reading `port_forwarding["internal_port"]`
directly would have raised `KeyError` when that attribute was missing too.
Zuul returned `Verified+1`.

This is why the abandoned changes stay in
[my register](/en/contributions/), listed as plainly as the merged ones. An
abandoned patch usually means the problem was framed wrong, or that a better
fix already existed, or, as here, that nobody had the time. None of those are
things to hide, and one of them turned back into a live change.

## What I would tell myself before the first push

Register the right email address first. Read the Zuul log before typing
`recheck`. Write the commit message as though the reviewer will only read
that.

And the one that would have actually changed the outcome: when the `-1`
arrives, open the comment the same week. Not because there is a deadline,
but because the distance between you and the change grows faster than you
expect, and two years later you will have to rebuild all of the context you
have right now, for free.

Twenty-three months passed between that review and the patch set that
answered it. The change is open again at the time of writing.
