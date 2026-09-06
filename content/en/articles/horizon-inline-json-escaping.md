---
title: "Why JSON embedded in a Horizon page deserved proper escaping"
date: 2026-10-20
draft: true
description: "A security fix on the OpenStack dashboard, and the class of problem it belongs to."
pillar: "Upstream"
tags: ["openstack", "horizon", "security", "django"]
---

## The pattern

Any dashboard eventually needs server-side data in the browser before the
user touches anything. Horizon's Resize Instance dialog is a good example:
to let you compare what an instance has now against what it would get, it
needs the whole flavor list up front. So the view builds the list in Python,
serialises it with `json.dumps()`, and hands the string to a template that
drops it into an inline `<script>` block.

Nothing about that is unusual. It avoids a round trip, it keeps the data and
the page consistent, and every framework has a blessed way of doing it. The
question is only what happens to a value in that list that contains
characters the page did not expect.

## Why HTML escaping and JavaScript escaping are not the same problem

### How the parser reads a script block

The contents of a `<script>` element are not parsed as HTML. That much is
well known, and it is what makes people comfortable putting arbitrary JSON
in there. What is less present in people's minds is that the *boundary* of
the element still is.

Before any JavaScript runs, the browser has to know where the script ends.
It finds out by scanning the raw text for the closing tag. That scan is a
text search, not an evaluation: it does not know it is looking at a JSON
string, it does not care about quoting, and it stops at the first sequence
that looks like the end of the element.

### The sequences that end it early

`json.dumps()` produces valid JSON. It escapes what a JSON parser cares
about: quotes, backslashes, control characters. It leaves `<`, `>` and `&`
exactly as it found them, and it is right to, because those three mean
nothing to a JSON parser.

They mean a great deal to an HTML tokenizer. A string value containing a
literal `</script>` passes through serialisation untouched, reaches the
page intact, and closes the element early. The JSON was never wrong. It just
stopped being the only thing on the page.

## What that allows

Everything after the point where the element closed is markup, interpreted
in the page's own origin, in the session of whoever opened it. That is the
whole mechanism, and it is the same one whatever the payload is.

Worth stating plainly: the three places this affected in Horizon all take
operator-controlled names, and creating a flavor, a volume type or a
metadata definition normally requires an administrator. There is no path
here from an unprivileged tenant to another tenant's session, which is why
the report was assessed as low severity, and that assessment is correct.

It is still worth fixing. An administrator who creates flavors from a script,
or an operator importing metadata definitions from somewhere else, is not
attacking anyone. They are the ones who get to discover what a stray angle
bracket does to their dashboard.

## What Django gives you

### `json_script` and what it guarantees

Django solved this years ago. `json_script` rewrites `<`, `>` and `&` as
`\u003C`, `\u003E` and `\u0026` before writing them out. Those are unicode
escape sequences inside the JSON string, so `JSON.parse()` hands back the
original characters: the decoded value is unchanged, and only the HTML
tokenizer sees anything different.

The table that does it lives in `django.utils.html._json_script_escapes`.
The leading underscore is the whole difficulty.

### Why the filter alone was not the answer here

`json_script` does not only escape. It emits the entire element, with its own
id and `type="application/json"`, and expects the JavaScript on the other
side to read it back through `document.getElementById()`. Adopting it means
changing the template and the script that consumes the data, at every call
site.

That is a larger change than this bug needs, and a larger change is a worse
backport. Stable branches are where this fix is most useful, since they are
what people are actually running.

## The change

So the change mirrors the escaping rather than adopting the element.
[Change 1002877](https://review.opendev.org/c/openstack/horizon/+/1002877)
adds one helper:

```python
_JSON_SCRIPT_ESCAPES = {
    ord('>'): '\\u003E',
    ord('<'): '\\u003C',
    ord('&'): '\\u0026',
}


def json_dumps_for_script(value):
    return json.dumps(value).translate(_JSON_SCRIPT_ESCAPES)
```

and calls it from the three views that serialise operator-controlled names
into an inline block: flavor names in the Resize Instance dialog, which is
the case that was reported, volume type names and descriptions in Create
Volume, and metadata definition resource types.

What it deliberately does not do is as important. It does not migrate
anything to `json_script`. It does not touch the AngularJS escaping that
already lives in the same module. It does not try to solve this at the
template layer, where the data has already been serialised and the
information about what it is has been lost.

There is something instructive in where the helper landed.
`horizon/utils/escape.py` already existed, contributed by Rackspace in 2016,
and its job was to stop AngularJS interpolation from being turned into an
XSS vector by rewriting `{$` and `$}` before they reached the template
engine. Same dashboard, same category of problem, a decade apart, a
different templating layer each time. When a codebase already has a module
named after escaping, that is rarely the last thing it will hold.

The report came from Sami Yessou, who also proposed escaping the JSON
output. I wrote the patch, the tests and the release note. The change closes
[bug #2163088](https://bugs.launchpad.net/horizon/+bug/2163088).

## The general rule

The rule this belongs to is short: **the boundary of an element is found
before its contents are interpreted.** A serialiser that is correct for the
content is not automatically correct for the boundary, because it was never
asked about the boundary.

That applies well beyond Horizon and well beyond Python. If anywhere in your
own code you write server-side data into an inline `<script>`, an inline
style, an HTML attribute, or a template that will be parsed twice, the same
question is worth asking: which parser sees this first, and does the thing
that produced it know that parser exists?

Most of the time the answer is that your framework has already thought about
it and you should use what it gives you. When you cannot, because the shape
of the output is fixed by code you are not changing today, then mirror what
the framework does and say in a comment that you are mirroring it. That is
what the docstring on that helper is for.
